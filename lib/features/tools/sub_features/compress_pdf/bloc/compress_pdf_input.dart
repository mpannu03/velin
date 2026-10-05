import 'dart:io';

import 'package:velin/engine/engine.dart';

/// User-facing model for the Compress PDF tool.
class CompressPdfToolInput {
  const CompressPdfToolInput({
    required this.filePath,
    required this.outputFilePath,
    this.quality = 75,
  });

  /// Quality accepted by [CompressPdfEngine]: 0 to 100.
  static const minQuality = 0;
  static const maxQuality = 100;

  final String filePath;
  final String outputFilePath;

  /// How much compression effort to spend, from [minQuality] to [maxQuality].
  /// The engine maps it onto a deflate level.
  final int quality;

  CompressPdfToolInput copyWith({
    String? filePath,
    String? outputFilePath,
    int? quality,
  }) {
    return CompressPdfToolInput(
      filePath: filePath ?? this.filePath,
      outputFilePath: outputFilePath ?? this.outputFilePath,
      quality: quality ?? this.quality,
    );
  }
}

extension CompressPdfMapper on CompressPdfToolInput {
  CompressPdfInput toCompressPdfInput() {
    return CompressPdfInput(
      file: File(filePath),
      compressionLevel: quality.clamp(
        CompressPdfToolInput.minQuality,
        CompressPdfToolInput.maxQuality,
      ),
    );
  }
}
