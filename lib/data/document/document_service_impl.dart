import 'dart:io';

import 'package:velin/core/document/document.dart';
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';

class DocumentServiceImpl implements DocumentService {
  DocumentServiceImpl({
    required this._filePicker,
    required this._documentRepository,
  });

  final DocumentFilePicker _filePicker;
  final DocumentRepository _documentRepository;

  @override
  Future<Result<Document?>> open() async {
    final allowedExtensions = DocumentType.values
        .expand((type) => type.fileExtensions)
        .toList();

    final fileResult = await _filePicker.pickFile(
      allowedExtensions: allowedExtensions,
    );

    final String path;

    switch (fileResult) {
      case Failure(:final failure):
        return Failure(failure);
      case Success(data: null):
        return const Success(null);
      case Success(data: final String data):
        path = data;
    }

    final type = DocumentType.fromPath(path);

    if (type == null) {
      return Failure(UnsupportedFileTypeFailure(path: path));
    }

    return _documentRepository.open(path, type);
  }

  @override
  Future<Result<Document>> openRecent(RecentDocument recentDocument) async {
    final path = recentDocument.path;

    if (!await File(path).exists()) {
      return Failure(FileNotFoundFailure(path: path));
    }

    return _documentRepository.open(path, recentDocument.documentType);
  }

  @override
  Result<void> close(Document document) {
    return _documentRepository.close(document.id);
  }

  @override
  Stream<List<Document>> watch() {
    return _documentRepository.watch();
  }
}
