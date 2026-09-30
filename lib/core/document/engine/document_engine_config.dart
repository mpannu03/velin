import 'package:flutter/widgets.dart';

class DocumentEngineConfig {
  const DocumentEngineConfig({
    this.backgroundColor,
    this.initialZoom,
    this.zoomStep,
  });

  final Color? backgroundColor;

  final double? initialZoom;
  final double? zoomStep;
}