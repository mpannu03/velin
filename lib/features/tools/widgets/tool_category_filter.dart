import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// A quiet filter bar that narrows the tools grid to a single category.
///
/// `selected == null` represents the "All" filter which shows every category.
class ToolCategoryFilter extends StatelessWidget {
  const ToolCategoryFilter({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ToolCategory? selected;
  final ValueChanged<ToolCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _FilterChip(
          label: context.l10n.toolsCategoryAll,
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        for (final category in ToolCategory.values)
          _FilterChip(
            label: category.label(context),
            selected: selected == category,
            onTap: () => onChanged(category),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: selected ? colorScheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + AppSpacing.xxs,
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
