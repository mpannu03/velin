import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/tools/registry/registry.dart';

/// Signature for loading a cached cover image for a recent document.
/// Provided by the smart layer so dumb widgets never touch repositories.
typedef RecentThumbnailLoader = Future<File?> Function(String path);

class HomeViewModel {
  HomeViewModel({
    required this.recentDocuments,
    required this.onRecentDocumentSelected,
    required this.onOpenDocument,
    required this.onBrowseTools,
    required this.onToolSelected,
    required this.thumbnailLoader,
    this.isOpening = false,
  });

  final List<RecentDocument> recentDocuments;

  final ValueChanged<RecentDocument> onRecentDocumentSelected;
  final VoidCallback onOpenDocument;
  final VoidCallback onBrowseTools;
  final ValueChanged<ToolDefinition> onToolSelected;
  final RecentThumbnailLoader thumbnailLoader;
  final bool isOpening;
}
