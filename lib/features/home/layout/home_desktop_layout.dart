import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';
import 'package:velin/shared/widgets/widgets.dart';

/// Home on desktop: covers of the latest documents to jump back in, then
/// the earlier ones in a sortable table. Searching covers every document.
class HomeDesktopLayout extends StatefulWidget {
  const HomeDesktopLayout({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeDesktopLayout> createState() => _HomeDesktopLayoutState();
}

class _HomeDesktopLayoutState extends State<HomeDesktopLayout> {
  RecentSortMode _sort = RecentSortMode.lastOpened;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final l10n = context.l10n;

    if (viewModel.recentDocuments.isEmpty) {
      return RecentEmptyState(
        isOpening: viewModel.isOpening,
        onOpenDocument: viewModel.onOpenDocument,
        onBrowseTools: viewModel.onBrowseTools,
      );
    }

    final latest = sortRecents(
      viewModel.recentDocuments,
      RecentSortMode.lastOpened,
    );
    final searching = _query.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Documents shown as covers are left out of the table, so
          // nothing appears twice. A search looks through everything.
          final onShelf = RecentShelf.itemsFor(constraints.maxWidth);
          final earlier = latest.skip(onShelf).toList();
          final rows = filterRecents(
            sortRecents(searching ? latest : earlier, _sort),
            _query,
          );
          final showTable = searching || earlier.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                title: l10n.homeJumpBackIn,
                isOpening: viewModel.isOpening,
                onOpenDocument: viewModel.onOpenDocument,
                onBrowseTools: viewModel.onBrowseTools,
              ),
              // Hidden rather than removed while searching, so the
              // search box below keeps its place in the tree (and its
              // focus and text).
              Visibility(
                visible: !searching,
                replacement: const SizedBox(height: AppSpacing.xl),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.xxl + AppSpacing.sm,
                  ),
                  child: RecentShelf(documents: latest, viewModel: viewModel),
                ),
              ),
              if (showTable) ...[
                Row(
                  children: [
                    Expanded(
                      child: HomeSectionTitle(
                        searching ? l10n.homeRecent : l10n.homeEarlier,
                        count: searching ? rows.length : earlier.length,
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
            ],
          );
        },
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
