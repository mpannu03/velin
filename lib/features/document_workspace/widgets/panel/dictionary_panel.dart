import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/services/dictionary/dictionary.dart';
import 'package:velin/shared/extensions/extensions.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../bloc/bloc.dart';
import 'empty_state_shell.dart';

class DictionaryPanel extends StatefulWidget {
  const DictionaryPanel({
    super.key,
    required this.dictionaryState,
    required this.onLookup,
    required this.onClear,
  });

  final DictionaryState dictionaryState;
  final ValueChanged<String> onLookup;
  final VoidCallback onClear;

  @override
  State<DictionaryPanel> createState() => _DictionaryPanelState();
}

class _DictionaryPanelState extends State<DictionaryPanel> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.dictionaryState.query ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant DictionaryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.dictionaryState.query ?? '';
    if (next != oldWidget.dictionaryState.query &&
        next != _controller.text &&
        _focusNode.hasFocus == false) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      _handleClear();
      return;
    }
    widget.onLookup(query);
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear();
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.dictionaryState;
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _handleSubmit(),
          decoration: InputDecoration(
            hintText: context.l10n.panelDictionaryHint,
            suffixIcon: hasText
                ? IconButton(
                    onPressed: _handleSubmit,
                    icon: const Icon(Symbols.search),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            if (state.query != null && state.query!.isNotEmpty)
              Expanded(
                child: Text(
                  state.query!,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            VelinToolButton(
              icon: Symbols.clear_all,
              toolTip: context.l10n.panelDictionaryClear,
              onPressed: _handleClear,
            ),
          ],
        ),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: LinearProgressIndicator(minHeight: AppSpacing.xxs),
          ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(child: _buildBody(context, state)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DictionaryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final query = state.query;
    if (query == null || query.trim().isEmpty) {
      return EmptyStateShell(
        icon: Symbols.dictionary,
        message: context.l10n.panelDictionaryEmpty,
      );
    }
    final entry = state.result;
    if (entry == null) {
      return EmptyStateShell(
        icon: Symbols.search_off,
        message: context.l10n.panelDictionaryNotFound,
      );
    }
    return _DictionaryResultView(entry: entry, onLookup: widget.onLookup);
  }
}

class _DictionaryResultView extends StatelessWidget {
  const _DictionaryResultView({required this.entry, required this.onLookup});

  final DictionaryEntry entry;
  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        Text(
          entry.word,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final language in entry.languages)
          _LanguageSection(language: language, onLookup: onLookup),
      ],
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({required this.language, required this.onLookup});

  final DictionaryLanguage language;
  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            0,
            AppSpacing.md,
            0,
            AppSpacing.xs,
          ),
          child: Text(
            language.name,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final pos in language.partsOfSpeech)
          _PartOfSpeechSection(partOfSpeech: pos, onLookup: onLookup),
      ],
    );
  }
}

class _PartOfSpeechSection extends StatelessWidget {
  const _PartOfSpeechSection({
    required this.partOfSpeech,
    required this.onLookup,
  });

  final DictionaryPartOfSpeech partOfSpeech;
  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              partOfSpeech.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < partOfSpeech.definitions.length; i++)
            _DefinitionTile(
              index: i + 1,
              definition: partOfSpeech.definitions[i],
              onLookup: onLookup,
            ),
        ],
      ),
    );
  }
}

class _DefinitionTile extends StatelessWidget {
  const _DefinitionTile({
    required this.index,
    required this.definition,
    required this.onLookup,
  });

  final int index;
  final DictionaryDefinition definition;
  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('$index. ${definition.definition}'),
          HtmlWidget(
            '$index. ${definition.definition}',
            onTapUrl: (url) {
              final word = extractWiktionaryWord(url);
              if (word != null) {
                onLookup(word);
              }
              return true;
            },
          ),
          for (final example in definition.examples)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                top: AppSpacing.xxs,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: HtmlWidget(
                  '"$example"',
                  onTapUrl: (url) {
                    final word = extractWiktionaryWord(url);
                    if (word != null) {
                      onLookup(word);
                    }
                    return true;
                  },
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String? extractWiktionaryWord(String href) {
  if (!href.startsWith('/wiki/')) {
    return null;
  }

  final path = href.substring('/wiki/'.length);
  final title = path.split('#').first;

  if (title.isEmpty) {
    return null;
  }

  return Uri.decodeComponent(title.replaceAll('_', ' '));
}
