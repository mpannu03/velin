import 'package:file_picker/file_picker.dart';
import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';

class DocumentFilePickerImpl implements DocumentFilePicker {
  @override
  Future<Result<String?>> pickFile({required List<String> allowedExtensions}) {
    return Result.guard(() async {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      return result?.path;
    });
  }

  @override
  Future<Result<List<String>>> pickFiles({
    required List<String> allowedExtensions,
  }) {
    return Result.guard(() async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      return result.map((file) => file.path).whereType<String>().toList();
    });
  }

  @override
  Future<Result<String?>> pickDirectory() {
    return Result.guard(FilePicker.getDirectoryPath);
  }
}
