import 'package:velin/core/error/error.dart';

mixin ErrorMessageMixin {
  String errorMessage(Object error) {
    if (error case VelinError(:final message)) {
      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}