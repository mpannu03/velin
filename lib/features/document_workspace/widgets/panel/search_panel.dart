import 'package:material_ui/material_ui.dart';
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

  /// List of search results to display.
  final List<TextSearchResult> results;

  /// Index of the currently selected result (highlighted).
  final int? currentIndex;

  /// Whether a search is currently in progress.
  final bool isLoading;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// The query that was actually submitted to search (used for highlighting).
  /// Kept separate from `_controller.text` so highlighting stays stable
  /// while the user edits the field before pressing search again.
  String _submittedQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    // Only rebuild so the clear (X) button shows/hides.
    // Do NOT trigger a search here.
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
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: _handleChanged,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Search in document...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear',
                            onPressed: _handleClear,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Explicit search button — triggers the heavy search.
              SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                widget.results.isEmpty
                    ? (_submittedQuery.isEmpty
                        ? 'Enter text to search'
                        : 'No results')
                    : '${widget.results.length} result${widget.results.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: widget.results.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
            Icon(
              Icons.search_off,
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

/// A single search result row, highlighting the matching query text.
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

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 14,
                    color: fgColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Page ${result.pageNumber}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fgColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _HighlightedText(
                text: result.text,
                query: query,
                baseStyle: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
                highlightColor: theme.colorScheme.primary,
                highlightTextColor: theme.colorScheme.onPrimary,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [text] with all occurrences of [query] highlighted.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
    required this.highlightTextColor,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle? baseStyle;
  final Color highlightColor;
  final Color highlightTextColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (true) {
      final matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex)));
      }
      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: TextStyle(
            backgroundColor: highlightColor,
            color: highlightTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = matchIndex + query.length;
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}