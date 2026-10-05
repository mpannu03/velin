import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/shared/extensions/extensions.dart';

class BySelectionEditor extends StatelessWidget {
  const BySelectionEditor({
    super.key,
    required this.selections,
    required this.onSelectionChanged,
    required this.onAddSelection,
    required this.onRemoveSelection,
  });

  final List<String> selections;
  final void Function(int index, String value) onSelectionChanged;
  final VoidCallback onAddSelection;
  final ValueChanged<int> onRemoveSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selections.isNotEmpty)
          for (var index = 0; index < selections.length; index++)
            Padding(
              key: ValueKey('selection-$index'),
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PageSelectionField(
                      value: selections[index],
                      fieldKey: ValueKey('selection-field-$index'),
                      onChanged: (value) => onSelectionChanged(
                        index,
                        value,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: () => onRemoveSelection(index),
                    tooltip: l10n.toolsSplitSelectionRemove,
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        if (selections.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              l10n.toolsSplitSelectionHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddSelection,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsSplitSelectionAdd),
          ),
        ),
      ],
    );
  }
}