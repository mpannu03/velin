import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/document/document.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/recent/recent.dart';
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
    test('returns the picker failure', () async {
      const failure = FileAccessDeniedFailure();

      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => const Failure<String?>(failure));

      final result = await service.open();

      expect(result.failureOrNull, same(failure));
      verifyNever(() => repository.open(any(), any()));
    });

    test('returns Success(null) when the picker is cancelled', () async {
      when(() => filePicker.pickFile(allowedExtensions: ['pdf']))
          .thenAnswer((_) async => const Success<String?>(null));

      final result = await service.open();

      expect(result, const Success<Document?>(null));
      verifyNever(() => repository.open(any(), any()));
    });

    test('fails with UnsupportedFileTypeFailure for unknown types', () async {
      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => const Success<String?>('/documents/file.txt'));

      final result = await service.open();

      expect(
        result.failureOrNull,
        isA<UnsupportedFileTypeFailure>().having(
          (f) => f.path,
          'path',
          '/documents/file.txt',
        ),
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
      ).thenAnswer((_) async => const Success<String?>('/documents/file.pdf'));

      when(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .thenReturn(Success(document));

      final result = await service.open();

      expect(result, Success(document));
      verify(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .called(1);
    });

    test('returns repository failure', () async {
      const failure = UnexpectedFailure();

      when(
        () => filePicker.pickFile(allowedExtensions: ['pdf']),
      ).thenAnswer((_) async => const Success<String?>('/documents/file.pdf'));

      when(() => repository.open('/documents/file.pdf', DocumentType.pdf))
          .thenReturn(const Failure<Document>(failure));

      final result = await service.open();

      expect(result.failureOrNull, same(failure));
    });
  });

  group('openRecent', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('velin_open_recent_');
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    RecentDocument recent(String path) => RecentDocument(
      path: path,
      pageCount: 3,
      currentPage: 1,
      lastOpenedAt: DateTime(2026),
      documentType: DocumentType.pdf,
    );

    test('fails with FileNotFoundFailure when the file is gone', () async {
      final path = p.join(tempDir.path, 'moved.pdf');

      final result = await service.openRecent(recent(path));

      expect(
        result.failureOrNull,
        isA<FileNotFoundFailure>().having((f) => f.path, 'path', path),
      );
      verifyNever(() => repository.open(any(), any()));
    });

    test('opens an existing file through the repository', () async {
      final file = File(p.join(tempDir.path, 'here.pdf'))
        ..writeAsStringSync('');
      final document = Document(path: file.path, type: DocumentType.pdf);

      when(() => repository.open(file.path, DocumentType.pdf))
          .thenReturn(Success(document));

      final result = await service.openRecent(recent(file.path));

      expect(result, Success(document));
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

      const failure = UnexpectedFailure();

      when(() => repository.close(document.id))
          .thenReturn(const Failure<void>(failure));

      final result = service.close(document);

      expect(result.failureOrNull, same(failure));
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
