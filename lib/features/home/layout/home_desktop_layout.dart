import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/widgets.dart';

class HomeDesktopLayout extends StatefulWidget {
  const HomeDesktopLayout({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeDesktopLayout> createState() => _HomeDesktopLayoutState();
}

class _HomeDesktopLayoutState extends State<HomeDesktopLayout> {
  RecentViewMode _mode = RecentViewMode.grid;
  RecentSortMode _sort = RecentSortMode.lastOpened;
  String _query = '';

  static const _maxContentWidth = 1120.0;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final docs = filterRecents(
      sortRecents(viewModel.recentDocuments, _sort),
      _query,
    );
    final hasRecents = viewModel.recentDocuments.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: HomeHero(
                        docCount: viewModel.recentDocuments.length,
                        isOpening: viewModel.isOpening,
                        onOpenDocument: viewModel.onOpenDocument,
                        onBrowseTools: viewModel.onBrowseTools,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      width: 280,
                      child: HomeStatsCard(
                        documents: viewModel.recentDocuments,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasRecents) ...[
                const SizedBox(height: AppSpacing.xl),
                ContinueReadingCard(
                  document: sortRecents(
                    viewModel.recentDocuments,
                    RecentSortMode.lastOpened,
                  ).first,
                  viewModel: viewModel,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              RecentSectionHeader(
                totalCount: viewModel.recentDocuments.length,
                mode: _mode,
                sort: _sort,
                query: _query,
                onModeChanged: (m) => setState(() => _mode = m),
                onSortChanged: (s) => setState(() => _sort = s),
                onQueryChanged: (q) => setState(() => _query = q),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!hasRecents)
                RecentEmptyState(
                  isOpening: viewModel.isOpening,
                  onOpenDocument: viewModel.onOpenDocument,
                )
              else if (docs.isEmpty)
                _NoResults(query: _query)
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _mode == RecentViewMode.grid
                      ? RecentGrid(
                          key: const ValueKey('grid'),
                          documents: docs,
                          viewModel: viewModel,
                        )
                      : RecentList(
                          key: const ValueKey('list'),
                          documents: docs,
                          viewModel: viewModel,
                        ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              HomeQuickActions(
                actions: [
                  HomeQuickAction(
                    icon: Icons.folder_open_outlined,
                    title: 'Open document',
                    description: 'Pick a PDF from your files',
                    onTap: viewModel.onOpenDocument,
                  ),
                  HomeQuickAction(
                    icon: Icons.construction_outlined,
                    title: 'PDF tools',
                    description: 'Merge, split, compress & more',
                    onTap: viewModel.onBrowseTools,
                  ),
                  HomeQuickAction(
                    icon: Icons.menu_book_outlined,
                    title: 'Continue reading',
                    description: hasRecents
                        ? 'Resume your latest document'
                        : 'Your recents will appear here',
                    onTap: hasRecents
                        ? () => viewModel.onRecentDocumentSelected(
                            sortRecents(
                              viewModel.recentDocuments,
                              RecentSortMode.lastOpened,
                            ).first,
                          )
                        : viewModel.onOpenDocument,
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        'No matches for "$query".',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
