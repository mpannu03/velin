import 'package:material_ui/material_ui.dart';

import '../view/view.dart';
import '../widgets/widgets.dart';

/// Toolbar on top; the page fills the rest, with the selected panel docked
/// on the right behind a hairline.
class DocumentWorkspaceDesktopLayout extends StatelessWidget {
  const DocumentWorkspaceDesktopLayout({required this.viewModel, super.key});

  final DocumentWorkspaceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final selectedPanel = viewModel.selectedPanel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DocumentWorkspaceToolbar(viewModel: viewModel),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DocumentWorkspaceViewport(
                  documentViewer: viewModel.documentViewer,
                ),
              ),
              if (selectedPanel != null) ...[
                const VerticalDivider(width: 1),
                DocumentWorkspacePanel(
                  panel: selectedPanel,
                  onClose: viewModel.onPanelClosed,
                  onTextSearch: viewModel.onTextSearch,
                  onClearSearch: viewModel.onClearSearch,
                  onTextSearchResultSelected:
                      viewModel.onTextSearchResultSelected,
                  searchState: viewModel.searchState,
                  bookmarks: viewModel.bookmarks,
                  onBookmarkSelected: viewModel.onBookmarkSelected,
                  annotations: viewModel.annotations,
                  onAnnotationSelected: viewModel.onAnnotationSelected,
                  dictionaryState: viewModel.dictionaryState,
                  onDictionaryLookup: viewModel.onDictionaryLookup,
                  onClearDictionary: viewModel.onClearDictionary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
