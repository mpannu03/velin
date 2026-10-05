import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';

class ToolCard extends StatefulWidget {
  const ToolCard({required this.tool, required this.onTap, super.key});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = _hovered
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLow;
    final borderColor = _focused
        ? colorScheme.primary
        : _hovered
        ? colorScheme.outlineVariant
        : colorScheme.outlineVariant.withValues(alpha: 0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconChip(icon: widget.tool.icon, hovered: _hovered),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: _hovered ? 1 : 0,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.tool.title(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.tool.description(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.hovered});

  final IconData icon;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = hovered
        ? colorScheme.primary
        : colorScheme.primaryContainer;
    final foreground = hovered
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: 24, color: foreground),
    );
  }
}
