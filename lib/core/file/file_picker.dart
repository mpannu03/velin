import 'package:velin/core/result/result.dart';

export 'file_picker_error.dart';

abstract interface class DocumentFilePicker {
  Future<Result<String>> pickFile({
    required List<String> allowedExtensions,
  });

  Future<Result<List<String>>> pickFiles({
    required List<String> allowedExtensions
  });
}