import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// Home on desktop: covers of the latest documents to jump back in, then
/// every recent document in a sortable, searchable table.
class HomeDesktopLayout extends StatefulWidget {
  const HomeDesktopLayout({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeDesktopLayout> createState() => _HomeDesktopLayoutState();
}

class _HomeDesktopLayoutState extends State<HomeDesktopLayout> {
  RecentSortMode _sort = RecentSortMode.lastOpened;
  String _query = '';

  static const _maxContentWidth = 1120.0;

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
    final rows = filterRecents(
      sortRecents(viewModel.recentDocuments, _sort),
      _query,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                title: l10n.homeJumpBackIn,
                isOpening: viewModel.isOpening,
                onOpenDocument: viewModel.onOpenDocument,
                onBrowseTools: viewModel.onBrowseTools,
              ),
              const SizedBox(height: AppSpacing.lg),
              RecentShelf(documents: latest, viewModel: viewModel),
              const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: HomeSectionTitle(
                      l10n.homeRecent,
                      count: viewModel.recentDocuments.length,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      onChanged: (q) => setState(() => _query = q),
                      decoration: InputDecoration(
                        hintText: l10n.homeSearchHint,
                        prefixIcon: const Icon(Icons.search, size: 16),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
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
