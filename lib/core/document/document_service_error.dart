import 'package:velin/core/error/error.dart';

class DocumentServiceError implements VelinError {
  const DocumentServiceError(this.message);

  @override
  final String message;
}