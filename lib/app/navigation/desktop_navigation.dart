import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_navigation.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    required this.selectedItem,
    required this.onItemSelected,
    super.key,
  });

  final AppNavigationItem selectedItem;
  final ValueChanged<AppNavigationItem> onItemSelected;

  static const _height = 44.0;
  static const _containerPadding = 4.0;
  static const _iconSize = 18.0;
  static const _horizontalItemPadding = 12.0;

  /// Measures the widest segment so the pill has a uniform width.
  double _measureSegmentWidth(TextStyle? textStyle, BuildContext context) {
    var widest = 0.0;
    for (final item in AppNavigationItem.values) {
      final tp = TextPainter(
        text: TextSpan(text: item.label(context), style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      // icon + gap + text + horizontal padding
      final w = _iconSize + AppSpacing.xs + tp.width + _horizontalItemPadding * 2;
      if (w > widest) widest = w;
    }
    return widest;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final segmentWidth = _measureSegmentWidth(textStyle, context);
    final containerWidth =
        segmentWidth * AppNavigationItem.values.length + 2 * _containerPadding;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: containerWidth,
                height: _height,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(_containerPadding),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: selectedItem.index * segmentWidth,
                        top: 0,
                        bottom: 0,
                        width: segmentWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final item in AppNavigationItem.values)
                            _NavigationItem(
                              item: item,
                              width: segmentWidth,
                              selected: item == selectedItem,
                              onPressed: () => onItemSelected(item),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.width,
    required this.selected,
    required this.onPressed,
  });

  final AppNavigationItem item;
  final double width;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fg = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.65);

    return SizedBox(
      width: width,
      height: DesktopNavigation._height,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesktopNavigation._horizontalItemPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: DesktopNavigation._iconSize, color: fg),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  item.label(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}