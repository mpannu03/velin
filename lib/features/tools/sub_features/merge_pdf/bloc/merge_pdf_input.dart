import 'dart:io';

import 'package:velin/core/page_selection/page_selection.dart';
import 'package:velin/engine/engine.dart';

class MergePdfToolInput {
  const MergePdfToolInput({required this.filePath, this.pageSelection});

  final String filePath;
  final String? pageSelection;

  MergePdfToolInput copyWith({String? pageSelection}) {
    return MergePdfToolInput(
      filePath: filePath,
      pageSelection: pageSelection ?? this.pageSelection,
    );
  }
}

extension MergePdfMapper on MergePdfToolInput {
  MergePdfInput toPdfInput() {
    final selectionText = pageSelection?.trim();

    if (selectionText == null || selectionText.isEmpty) {
      return MergePdfInput(file: File(filePath));
    }

    return MergePdfInput(
      file: File(filePath),
      selection: PageSelectionParser().parse(selectionText),
    );
  }
}
