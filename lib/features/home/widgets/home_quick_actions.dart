import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class HomeQuickAction {
  const HomeQuickAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
}

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({required this.actions, super.key});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minCardWidth = 240.0;
        final columns = (constraints.maxWidth / minCardWidth).floor().clamp(
          1,
          3,
        );
        const gap = AppSpacing.lg;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _QuickActionCard(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({required this.action});

  final HomeQuickAction action;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: _hovered
            ? colors.surfaceContainerHigh
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: _hovered
                ? colors.outlineVariant
                : colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.action.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _hovered ? colors.primary : colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    widget.action.icon,
                    size: 22,
                    color: _hovered
                        ? colors.onPrimary
                        : colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.action.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.action.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: _hovered ? 1 : 0,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
