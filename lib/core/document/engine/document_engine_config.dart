import 'package:flutter/widgets.dart';

class DocumentEngineConfig {
  const DocumentEngineConfig({
    required this.backgroundColor,
    this.initialZoom,
    this.zoomStep,
  });

  final Color backgroundColor;

  final double? initialZoom;
  final double? zoomStep;
}