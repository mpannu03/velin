import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'widgets.dart';

class PageScopeEditor extends StatelessWidget {
  const PageScopeEditor({
    super.key,
    required this.scope,
    required this.selection,
    required this.onScopeChanged,
    required this.onSelectionChanged,
  });

  final WatermarkPageScope scope;
  final String selection;

  final ValueChanged<WatermarkPageScope> onScopeChanged;
  final ValueChanged<String> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WatermarkPageScope>(
          key: const ValueKey('add-watermark-scope'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkPageScope.allPages,
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: Text(l10n.toolsWatermarkScopeAll),
            ),
            ButtonSegment(
              value: WatermarkPageScope.selectedPages,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.toolsWatermarkScopeSelected),
            ),
          ],
          selected: {scope},
          onSelectionChanged: (selection) =>
              onScopeChanged(selection.first),
        ),
        if (scope.requiresSelection) ...[
          const SizedBox(height: AppSpacing.lg),
          PageSelectionField(
            value: selection,
            fieldKey: const ValueKey('add-watermark-page-selection'),
            width: 260,
            hintText: l10n.toolsWatermarkSelectionHint,
            onChanged: onSelectionChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          HelperText(l10n.toolsWatermarkSelectionHelper),
        ],
      ],
    );
  }
}