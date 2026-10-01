import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/document/engine/engine.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({
    super.key,
    required this.onTextSearch,
    required this.onClearSearch,
    required this.onTextSearchResultSelected,
    required this.results,
    required this.currentIndex,
    required this.isLoading,
  });

  final Function(String text) onTextSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<TextSearchResult> onTextSearchResultSelected;

  final List<TextSearchResult> results;

  final int? currentIndex;

  final bool isLoading;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _submittedQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  void _handleSubmit() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      _handleClear();
      return;
    }
    setState(() {
      _submittedQuery = query;
    });
    widget.onTextSearch(query);
  }

  void _handleClear() {
    _controller.clear();
    _submittedQuery = '';
    widget.onClearSearch();
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => _handleChange(),
                onSubmitted: (_) => _handleSubmit(),
                decoration: InputDecoration(
                  hintText: 'Search in document...',
                  suffixIcon: hasText
                      ? IconButton(
                          onPressed: _handleSubmit, 
                          icon: const Icon(Symbols.search)
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Spacer(),
            _iconButton(Symbols.clear_all, _handleClear, 'Clear search')
          ],
        ),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: LinearProgressIndicator(minHeight: AppSpacing.xxs),
          ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: widget.isLoading
              ? CircularProgressIndicator()
              : widget.results.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      itemCount: widget.results.length,
                  itemBuilder: (context, i) {
                    final result = widget.results[i];
                    final isSelected = widget.currentIndex == result.index;
                    return SearchResultItem(
                      result: result,
                      query: _submittedQuery,
                      isSelected: isSelected,
                      onTap: () => widget.onTextSearchResultSelected(result),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _submittedQuery.isEmpty
                ? Icon(
                    Symbols.search,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  )
                : Icon(
                    Symbols.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
            const SizedBox(height: 12),
            Text(
              _submittedQuery.isEmpty
                  ? 'Enter text to search'
                  : 'No matches found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
    this.isSelected = false,
  });

  final TextSearchResult result;
  final String query;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;
    final fgColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    
    final borderRadius = BorderRadius.circular(AppRadius.md);

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, 
            vertical: AppSpacing.sm
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Page ${result.pageNumber}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fgColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(result.text),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _iconButton(
  IconData icon, 
  VoidCallback 
  onPressed, String 
  tooltip, 
  [double? size]
) {
  return Tooltip(
    message: tooltip,
    child: IconButton(
      onPressed: () => onPressed(),
      icon: Icon(icon, size: size ?? 18),
      padding: EdgeInsets.all(AppSpacing.xs),
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
      ),
    ),
  );
}