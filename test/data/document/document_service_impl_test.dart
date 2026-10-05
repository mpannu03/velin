import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:velin/core/document/document.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/data/document/document_service_impl.dart';

class MockDocumentFilePicker extends Mock implements DocumentFilePicker {}

class MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late MockDocumentFilePicker filePicker;
  late MockDocumentRepository repository;
  late DocumentServiceImpl service;

  setUpAll(() {
    registerFallbackValue(DocumentType.pdf);
  });

  setUp(() {
    filePicker = MockDocumentFilePicker();
    repository = MockDocumentRepository();
    service = DocumentServiceImpl(
      filePicker: filePicker,
      documentRepository: repository,
    );
  });

  group('open', () {
    test('returns failure when file picker fails', () async {
      const error = DocumentFilePickerError('Failed to pick file.');

      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => const Failure<String>(error));

      final result = await service.open();

      expect(result, const Failure<Document>(error));

      verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);

      verifyNever(() => repository.open(any(), any()));
    });

    test('returns failure when document type is unsupported', () async {
      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => const Success<String>('/documents/file.txt'));

      final result = await service.open();

      expect(result, isA<Failure<Document>>());

      final failure = result as Failure<Document>;

      expect(failure.error, isA<VelinError>());
      expect(
        (failure.error as VelinError).message,
        'Unsupported document type.',
      );

      verifyNever(() => repository.open(any(), any()));
    });

    test('opens selected document through repository', () async {
      final document = Document(
        path: '/documents/file.pdf',
        type: DocumentType.pdf,
      );

      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => const Success<String>('/documents/file.pdf'));

      when(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .thenReturn(Success(document));

      final result = await service.open();

      expect(result, Success(document));

      verify(() => filePicker.pickFile(allowedExtensions: ['pdf'])).called(1);

      verify(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .called(1);
    });

    test('returns repository failure', () async {
      const error = DocumentServiceError('Could not open document.');

      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => const Success<String>('/documents/file.pdf'));

      when(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .thenReturn(const Failure<Document>(error));

      final result = await service.open();

      expect(result, const Failure<Document>(error));
    });
  });

  group('close', () {
    test('closes document through repository', () {
      final document = Document(
        path: '/documents/file.pdf',
        type: DocumentType.pdf,
      );

      when(() => repository.close(document.id))
          .thenReturn(const Success<void>(null));

      final result = service.close(document);

      expect(result, const Success<void>(null));

      verify(() => repository.close(document.id)).called(1);
    });

    test('returns repository failure', () {
      final document = Document(
        path: '/documents/file.pdf',
        type: DocumentType.pdf,
      );

      const error = DocumentServiceError('Could not close document.');

      when(() => repository.close(document.id))
          .thenReturn(const Failure<void>(error));

      final result = service.close(document);

      expect(result, const Failure<void>(error));

      verify(() => repository.close(document.id)).called(1);
    });
  });

  group('watch', () {
    test('returns repository stream', () {
      final stream = Stream<List<Document>>.empty();

      when(() => repository.watch()).thenAnswer((_) => stream);

      expect(service.watch(), same(stream));

      verify(() => repository.watch()).called(1);
    });
  });
}
