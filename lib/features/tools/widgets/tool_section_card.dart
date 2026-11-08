import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

/// A titled section of a tool form.
///
/// Flat: sections are told apart by their headings and spacing, not by
/// boxes, which keeps forms calm when several sections stack up.
class ToolSectionCard extends StatelessWidget {
  const ToolSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;

  /// Shown at the end of the heading row, e.g. an "Add files" button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSectionHeader(title: title, trailing: trailing),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

/// The heading row of a [ToolSectionCard], for sections that lay out their
/// own content.
class ToolSectionHeader extends StatelessWidget {
  const ToolSectionHeader({
    super.key,
    required this.title,
    this.badge,
    this.trailing,
  });

  final String title;

  /// Small secondary text after the title, e.g. "3 files".
  final String? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              badge!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
