import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';

import '../helper_text.dart';
import 'page_selection_field.dart';

/// Which-pages selector shared by every tool that can operate on a subset of
/// pages.
///
/// Each tool declares its own scope enum (`WatermarkPageScope`,
/// `RotatePdfPageScope`, `PdfToImagePageScope`, ...), so this widget is generic
/// over the enum type [T] and takes [requiresSelection] as a plain bool rather
/// than knowing about any one of them. The icons, field width and layout are
/// identical across tools; only the labels, keys and enum differ.
class PageScopeEditor<T> extends StatelessWidget {
  const PageScopeEditor({
    required this.allPagesScope,
    required this.selectedPagesScope,
    required this.scope,
    required this.requiresSelection,
    required this.allPagesLabel,
    required this.selectedPagesLabel,
    required this.onScopeChanged,
    required this.selection,
    required this.onSelectionChanged,
    this.scopeKey,
    this.selectionFieldKey,
    this.selectionHintText,
    this.selectionHelperText,
    this.selectionFieldWidth = 260,
    super.key,
  });

  /// Scope meaning "every page"; from the tool's own scope enum.
  final T allPagesScope;

  /// Scope meaning "an explicit selection"; from the tool's own scope enum.
  final T selectedPagesScope;

  /// Currently selected scope.
  final T scope;

  /// Whether [scope] needs an explicit page selection. Pass
  /// `scope.requiresSelection` from the tool's own scope enum.
  final bool requiresSelection;

  final String allPagesLabel;
  final String selectedPagesLabel;

  /// Key applied to the scope segmented button, used by widget tests.
  final Key? scopeKey;

  /// Raw page-selection text, e.g. `1-5, 8, last`.
  final String selection;

  final ValueChanged<T> onScopeChanged;
  final ValueChanged<String> onSelectionChanged;

  /// Key applied to the inner page-selection field.
  final Key? selectionFieldKey;

  final String? selectionHintText;

  /// Explains the selection syntax; omit to show no helper line.
  final String? selectionHelperText;

  final double selectionFieldWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<T>(
          key: scopeKey,
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: allPagesScope,
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: Text(allPagesLabel),
            ),
            ButtonSegment(
              value: selectedPagesScope,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(selectedPagesLabel),
            ),
          ],
          selected: {scope},
          onSelectionChanged: (selection) => onScopeChanged(selection.first),
        ),
        if (requiresSelection) ...[
          const SizedBox(height: AppSpacing.lg),
          PageSelectionField(
            value: selection,
            fieldKey: selectionFieldKey,
            width: selectionFieldWidth,
            hintText: selectionHintText,
            onChanged: onSelectionChanged,
          ),
          if (selectionHelperText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            HelperText(selectionHelperText!),
          ],
        ],
      ],
    );
  }
}
