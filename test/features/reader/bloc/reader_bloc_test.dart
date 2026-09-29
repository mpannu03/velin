import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/features/reader/bloc/bloc.dart';

class MockDocumentService extends Mock implements DocumentService {}

class MockAppEffectController extends Mock
    implements AppEffectController {}

void main() {
  setUpAll(() {
    registerFallbackValue(NotificationType.error);
  });

  group('ReaderBloc', () {
    late MockDocumentService documentService;
    late MockAppEffectController effectController;
    late Document firstDocument;
    late Document secondDocument;

    setUp(() {
      documentService = MockDocumentService();
      effectController = MockAppEffectController();

      firstDocument = Document(
        path: r'C:\Documents\first.pdf',
        type: DocumentType.pdf,
      );

      secondDocument = Document(
        path: r'C:\Documents\second.pdf',
        type: DocumentType.pdf,
      );
    });

    ReaderBloc buildBloc() {
      return ReaderBloc(
        documentService: documentService,
        appEffectController: effectController,
      );
    }

    group('ReaderStarted', () {
      blocTest<ReaderBloc, ReaderState>(
        'emits loading then loaded documents',
        setUp: () {
          when(
            () => documentService.watch(),
          ).thenAnswer(
            (_) => Stream.value([
              firstDocument,
              secondDocument,
            ]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ReaderStarted()),
        expect: () => [
          isA<ReaderLoading>(),
          isA<ReaderLoaded>()
              .having(
                (state) => state.documents,
                'documents',
                [firstDocument, secondDocument],
              )
              .having(
                (state) => state.selectedDocument,
                'selectedDocument',
                same(firstDocument),
              ),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'selects null when watched documents are empty',
        setUp: () {
          when(
            () => documentService.watch(),
          ).thenAnswer(
            (_) => Stream.value(const <Document>[]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ReaderStarted()),
        expect: () => [
          isA<ReaderLoading>(),
          isA<ReaderLoaded>()
              .having(
                (state) => state.documents,
                'documents',
                isEmpty,
              )
              .having(
                (state) => state.selectedDocument,
                'selectedDocument',
                isNull,
              ),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'emits ReaderError when document stream fails',
        setUp: () {
          when(
            () => documentService.watch(),
          ).thenAnswer(
            (_) => Stream.error(Exception('Failed to watch documents')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ReaderStarted()),
        expect: () => [
          isA<ReaderLoading>(),
          isA<ReaderError>().having(
            (state) => state.message,
            'message',
            contains('Something went wrong. Please try again.'),
          ),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'keeps selected document when it is still present in updates',
        setUp: () {
          final controller = StreamController<List<Document>>();

          when(
            () => documentService.watch(),
          ).thenAnswer((_) => controller.stream);

          addTearDown(controller.close);

          controller.add([
            firstDocument,
            secondDocument,
          ]);
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const ReaderStarted());

          await Future<void>.delayed(Duration.zero);

          bloc.add(
            ReaderDocumentSelected(secondDocument),
          );

          await Future<void>.delayed(Duration.zero);
        },
        expect: () => [
          isA<ReaderLoading>(),
          isA<ReaderLoaded>()
              .having(
                (state) => state.selectedDocument,
                'selectedDocument',
                same(firstDocument),
              ),
          isA<ReaderLoaded>()
              .having(
                (state) => state.selectedDocument,
                'selectedDocument',
                same(secondDocument),
              ),
        ],
      );
    });

    group('ReaderDocumentSelected', () {
      blocTest<ReaderBloc, ReaderState>(
        'selects document when it exists in loaded documents',
        build: buildBloc,
        seed: () => ReaderLoaded(
          documents: [
            firstDocument,
            secondDocument,
          ],
          selectedDocument: firstDocument,
        ),
        act: (bloc) {
          bloc.add(
            ReaderDocumentSelected(secondDocument),
          );
        },
        expect: () => [
          isA<ReaderLoaded>().having(
            (state) => state.selectedDocument,
            'selectedDocument',
            same(secondDocument),
          ),
        ],
      );

      blocTest<ReaderBloc, ReaderState>(
        'does not emit when document does not exist',
        build: buildBloc,
        seed: () => ReaderLoaded(
          documents: [firstDocument],
          selectedDocument: firstDocument,
        ),
        act: (bloc) {
          bloc.add(
            ReaderDocumentSelected(secondDocument),
          );
        },
        expect: () => [],
      );

      blocTest<ReaderBloc, ReaderState>(
        'does not emit when state is not loaded',
        build: buildBloc,
        act: (bloc) {
          bloc.add(
            ReaderDocumentSelected(firstDocument),
          );
        },
        expect: () => [],
      );
    });

    group('ReaderDocumentOpened', () {
      blocTest<ReaderBloc, ReaderState>(
        'opens document without emitting state on success',
        setUp: () {
          when(
            () => documentService.open(),
          ).thenAnswer(
            (_) async => Success(firstDocument),
          );
        },
        build: buildBloc,
        act: (bloc) {
          bloc.add(const ReaderDocumentOpened());
        },
        expect: () => [],
        verify: (_) {
          verify(() => documentService.open()).called(1);
          verifyNever(
            () => effectController.notifyUser(
              message: any(named: 'message'),
              type: any(named: 'type'),
            ),
          );
        },
      );

      blocTest<ReaderBloc, ReaderState>(
        'shows error effect when opening document fails',
        setUp: () {
          when(
            () => documentService.open(),
          ).thenAnswer(
            (_) async => Failure(DocumentServiceError('Could not open document')),
          );
        },
        build: buildBloc,
        act: (bloc) {
          bloc.add(const ReaderDocumentOpened());
        },
        expect: () => [],
        verify: (_) {
          verify(() => documentService.open()).called(1);

          verify(
            () => effectController.notifyUser(
              message: 'Could not open document',
              type: NotificationType.error,
            ),
          ).called(1);
        },
      );
    });

    group('ReaderDocumentClosed', () {
      blocTest<ReaderBloc, ReaderState>(
        'closes document without emitting state on success',
        setUp: () {
          when(
            () => documentService.close(firstDocument),
          ).thenReturn(
            const Success<void>(null),
          );
        },
        build: buildBloc,
        act: (bloc) {
          bloc.add(
            ReaderDocumentClosed(firstDocument),
          );
        },
        expect: () => [],
        verify: (_) {
          verify(
            () => documentService.close(firstDocument),
          ).called(1);

          verifyNever(
            () => effectController.notifyUser(
              message: any(named: 'message'),
              type: any(named: 'type'),
            ),
          );
        },
      );

      blocTest<ReaderBloc, ReaderState>(
        'shows error effect when closing document fails',
        setUp: () {
          when(
            () => documentService.close(firstDocument),
          ).thenReturn(
            const Failure<void>(DocumentServiceError('Could not close document')),
          );
        },
        build: buildBloc,
        act: (bloc) {
          bloc.add(
            ReaderDocumentClosed(firstDocument),
          );
        },
        expect: () => [],
        verify: (_) {
          verify(
            () => documentService.close(firstDocument),
          ).called(1);

          verify(
            () => effectController.notifyUser(
              message: 'Could not close document',
              type: NotificationType.error,
            ),
          ).called(1);
        },
      );
    });
  });
}