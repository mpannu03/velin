import 'package:velin/core/result/result.dart';

abstract interface class DocumentFilePicker {
  Future<Result<String>> pickFile({
    required List<String> allowedExtensions,
  });
}