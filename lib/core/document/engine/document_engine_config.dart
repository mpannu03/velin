import 'package:flutter/widgets.dart';

class DocumentEngineConfig {
  const DocumentEngineConfig({
    this.backgroundColor,
    this.initialZoom,
    this.zoomStep,
    this.passwordProvider,
    this.initialPageNumber,
  });

  final Color? backgroundColor;

  final double? initialZoom;
  final double? zoomStep;
  final Future<String?> Function()? passwordProvider;
  final int? initialPageNumber;
}
