import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';

enum SplitPdfMode { bySelection, byPageCount, extractAllPages }

class SplitPdfInput {
  const SplitPdfInput({
    required this.file,
    required this.mode,
    this.selections = const [],
    this.pageCount,
  });

  final File file;
  final SplitPdfMode mode;

  /// Each selection produces a separate PDF.
  final List<PageSelection> selections;

  /// Number of pages per output PDF.
  final int? pageCount;
}
