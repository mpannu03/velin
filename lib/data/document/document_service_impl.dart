import 'package:velin/core/document/document.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';

class DocumentServiceImpl implements DocumentService {
  DocumentServiceImpl({
    required this._filePicker,
    required this._documentRepository,
  });

  final DocumentFilePicker _filePicker;
  final DocumentRepository _documentRepository;

  @override
  Future<Result<Document>> open() async {
    final allowedExtensions = DocumentType.values
        .expand((type) => type.fileExtensions)
        .toList();

    final fileResult = await _filePicker.pickFile(
      allowedExtensions: allowedExtensions,
    );

    if (fileResult case Failure<String>(:final error, :final stackTrace)) {
      return Failure(error, stackTrace);
    }

    final path = (fileResult as Success<String>).data;
    final type = DocumentType.fromPath(path);

    if (type == null) {
      return const Failure(DocumentServiceError('Unsupported document type.'));
    }

    return _documentRepository.open(path, type);
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
