import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/error/app_failure.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/rendering/rendering.dart';

/// Runs around every test file.
///
/// Widget tests never load pdfium, so file pickers that preview the
/// selected PDF get a renderer that reports "no preview" right away. Tests
/// that need a real or scripted renderer register their own first.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    if (!getIt.isRegistered<PdfPageRenderer>()) {
      getIt.registerSingleton<PdfPageRenderer>(NoPreviewPageRenderer());
    }
  });

  await testMain();
}

class NoPreviewPageRenderer extends PdfPageRenderer {
  @override
  Future<Result<PdfPreviewDocument>> openPreview(String path) async {
    return Failure(FileNotFoundFailure(path: path));
  }
}
