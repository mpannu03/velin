import 'package:flutter/widgets.dart';

class DocumentEngineConfig {
  const DocumentEngineConfig({
    this.backgroundColor,
    this.initialZoom,
    this.zoomStep,
    this.passwordProvider,
  });

  final Color? backgroundColor;

  final double? initialZoom;
  final double? zoomStep;
  final Future<String?> Function()? passwordProvider;
}
