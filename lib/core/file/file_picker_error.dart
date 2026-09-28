import 'package:velin/core/error/error.dart';

class DocumentFilePickerError implements VelinError {
  const DocumentFilePickerError(this.message);

  @override
  final String message;
}