import 'package:material_ui/material_ui.dart';
import 'package:velin/core/recent/recent.dart';

class HomeViewModel {
  HomeViewModel({
    required this.recentDocuments,
    required this.onRecentDocumentSelected,
  });

  final List<RecentDocument> recentDocuments;

  final ValueChanged<RecentDocument> onRecentDocumentSelected;
}
