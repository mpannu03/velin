import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/file/file_picker.dart';

import 'package:velin/core/result/result.dart';

class DocumentFilePickerError implements VelinError {
  const DocumentFilePickerError(this.message);

  @override
  final String message;
}

class DocumentFilePickerImpl implements DocumentFilePicker {
  @override
  Future<Result<String>> pickFile({
    required List<String> allowedExtensions,
  }) async {
    try {
      final result = await file_picker.FilePicker.pickFile(
        type: file_picker.FileType.custom,
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
}