import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

enum WorkspacePanel {
  comments,
  bookmarks,
  search
}

extension WorkplacePanelLabel on WorkspacePanel {
  String label(BuildContext context) {
    return switch (this) {
      WorkspacePanel.comments => context.l10n.panelComments,
      WorkspacePanel.bookmarks => context.l10n.panelBookmarks,
      WorkspacePanel.search => context.l10n.panelSearch,
    };
  }
}