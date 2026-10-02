import 'package:file_picker/file_picker.dart';
import 'package:velin/core/file/file_picker.dart';

import 'package:velin/core/result/result.dart';

class DocumentFilePickerImpl implements DocumentFilePicker {
  @override
  Future<Result<String>> pickFile({
    required List<String> allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      final path = result?.path;

      if (path == null) {
        return const Failure(
          DocumentFilePickerError('No file was selected.'),
        );
      }

      return Success(path);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }

  @override
  Future<Result<List<String>>> pickFiles({
    required List<String> allowedExtensions
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result.isEmpty) {
        return const Failure(
          DocumentFilePickerError('No files were selected.'),
        );
      }

      return Success(
        result.map(
          (file) => file.path
        ).whereType<String>().toList()
      );
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}