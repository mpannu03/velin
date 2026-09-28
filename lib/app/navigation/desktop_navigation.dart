import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_navigation.dart';
import 'package:velin/app/theme/theme.dart';

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    required this.selectedItem,
    required this.onItemSelected,
    super.key,
  });

  final AppNavigationItem selectedItem;
  final ValueChanged<AppNavigationItem> onItemSelected;

  static const _height = 44.0;
  static const _segmentWidth = 108.0;
  static const _containerPadding = 4.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: _segmentWidth 
                    * AppNavigationItem.values.length 
                    + 2 * DesktopNavigation._containerPadding,
                height: _height,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(DesktopNavigation._containerPadding),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: selectedItem.index * _segmentWidth,
                        top: 0,
                        bottom: 0,
                        width: _segmentWidth,
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
    required this.selected,
    required this.onPressed,
  });

  final AppNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: DesktopNavigation._segmentWidth,
      height: DesktopNavigation._height,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 16,
                color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              SizedBox(width: 4),
              Text(
                item.label,
                style: textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}