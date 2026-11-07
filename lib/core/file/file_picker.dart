import 'package:velin/core/result/result.dart';

/// Native file and folder pickers.
///
/// Cancelling is not a failure: [pickFile] and [pickDirectory] return
/// `Success(null)` and [pickFiles] returns `Success([])`. A [Failure] means
/// the picker itself could not be shown or returned an error.
abstract interface class DocumentFilePicker {
  Future<Result<String?>> pickFile({required List<String> allowedExtensions});

  Future<Result<List<String>>> pickFiles({
    required List<String> allowedExtensions,
  });

  Future<Result<String?>> pickDirectory();
}
