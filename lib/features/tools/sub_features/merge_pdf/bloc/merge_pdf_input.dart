// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  bool operator ==(covariant MergePdfToolInput other) {
    if (identical(this, other)) return true;

    return other.filePath == filePath && other.pageSelection == pageSelection;
  }

  @override
  int get hashCode => filePath.hashCode ^ pageSelection.hashCode;
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
