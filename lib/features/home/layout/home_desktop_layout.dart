import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';
import 'package:velin/shared/widgets/widgets.dart';

/// Home on desktop: covers of the latest documents to jump back in and a
/// sortable, searchable table of all of them; the most used tools sit in a
/// side pane (inline under the covers on narrow windows).
class HomeDesktopLayout extends StatefulWidget {
  const HomeDesktopLayout({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  /// Narrower than this, the tools pane folds into the page.
  static const sidePaneBreakpoint = 1000.0;

  @override
  State<HomeDesktopLayout> createState() => _HomeDesktopLayoutState();
}

class _HomeDesktopLayoutState extends State<HomeDesktopLayout> {
  RecentSortMode _sort = RecentSortMode.lastOpened;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final withPane =
            constraints.maxWidth >= HomeDesktopLayout.sidePaneBreakpoint;

        final documents = viewModel.recentDocuments.isEmpty
            ? RecentEmptyState(
                isOpening: viewModel.isOpening,
                onOpenDocument: viewModel.onOpenDocument,
                onBrowseTools: viewModel.onBrowseTools,
              )
            : _buildDocuments(context, viewModel, inlineTools: !withPane);

        if (!withPane) return documents;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: documents),
            const VerticalDivider(width: 1),
            SizedBox(
              width: HomeToolsPane.width,
              child: HomeToolsPane(
                onToolSelected: viewModel.onToolSelected,
                onBrowseTools: viewModel.onBrowseTools,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocuments(
    BuildContext context,
    HomeViewModel viewModel, {
    required bool inlineTools,
  }) {
    final l10n = context.l10n;
    final latest = sortRecents(
      viewModel.recentDocuments,
      RecentSortMode.lastOpened,
    );
    final searching = _query.trim().isNotEmpty;
    final rows = filterRecents(sortRecents(latest, _sort), _query);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            title: l10n.homeJumpBackIn,
            isOpening: viewModel.isOpening,
            onOpenDocument: viewModel.onOpenDocument,
          ),
          // Hidden rather than removed while searching, so the search box
          // below keeps its place in the tree (and its focus and text).
          Visibility(
            visible: !searching,
            replacement: const SizedBox(height: AppSpacing.xl),
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.xxl + AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RecentShelf(documents: latest, viewModel: viewModel),
                  if (inlineTools) ...[
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
                    HomeQuickTools(
                      onToolSelected: viewModel.onToolSelected,
                      onBrowseTools: viewModel.onBrowseTools,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: HomeSectionTitle(
                  searching ? l10n.homeRecent : l10n.homeAllDocuments,
                  count: rows.length,
                ),
              ),
              SearchField(
                hintText: l10n.homeSearchHint,
                onChanged: (q) => setState(() => _query = q),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (rows.isEmpty)
            _NoResults(query: _query)
          else
            RecentTable(
              documents: rows,
              viewModel: viewModel,
              sort: _sort,
              onSortChanged: (s) => setState(() => _sort = s),
            ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Text(
        context.l10n.homeNoMatches(query),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
