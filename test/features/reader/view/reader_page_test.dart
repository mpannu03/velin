import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/features/reader/reader.dart';

import '../../../helpers/helpers.dart';

class MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(ReaderStarted());
  });

  group('ReaderPage', () {
    late MockReaderBloc bloc;
    late Document document;

    setUp(() {
      bloc = MockReaderBloc();

      document = Document(
        path: r'C:\Documents\example.pdf',
        type: DocumentType.pdf,
      );

      getIt.registerFactory<ReaderBloc>(() => bloc);
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: const ReaderLoading(),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ReaderView), findsNothing);
    });

    testWidgets('shows reader view when loaded', (tester) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: ReaderLoaded(
          documents: [],
        ),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      expect(find.byType(ReaderView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message when loading fails', (tester) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: const ReaderError('Failed to load documents'),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      expect(find.text('Failed to load documents'), findsOneWidget);
    });

    testWidgets('starts reader when page is created', (tester) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: ReaderLoaded(
          documents: [],
        ),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      verify(() => bloc.add(const ReaderStarted())).called(1);
    });

    testWidgets('adds document selected event from view model callback', (
      tester,
    ) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: ReaderLoaded(
          documents: [document],
          selectedDocument: document,
        ),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      final view = tester.widget<ReaderView>(
        find.byType(ReaderView),
      );

      view.viewModel.onDocumentSelected(document);

      verify(
        () => bloc.add(any(that: isA<ReaderDocumentSelected>())),
      ).called(1);
    });

    testWidgets('adds document closed event from view model callback', (
      tester,
    ) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: ReaderLoaded(
          documents: [document],
          selectedDocument: document,
        ),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      final view = tester.widget<ReaderView>(
        find.byType(ReaderView),
      );

      view.viewModel.onDocumentClosed(document);

      verify(
        () => bloc.add(any(that: isA<ReaderDocumentClosed>())),
      ).called(1);
    });

    testWidgets('adds open document event from view model callback', (
      tester,
    ) async {
      whenListen(
        bloc,
        const Stream<ReaderState>.empty(),
        initialState: ReaderLoaded(
          documents: [document],
          selectedDocument: document,
        ),
      );

      await pumpApp(
        tester,
        const ReaderPage(),
      );

      final view = tester.widget<ReaderView>(
        find.byType(ReaderView),
      );

      view.viewModel.onOpenDocument();

      verify(
        () => bloc.add(const ReaderDocumentOpened()),
      ).called(1);
    });
  });
}