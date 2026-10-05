import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_navigation.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/i10n_ext.dart';

class MobileNavigation extends StatelessWidget {
  const MobileNavigation({
    required this.selectedItem,
    required this.onItemSelected,
    super.key,
  });

  final AppNavigationItem selectedItem;
  final ValueChanged<AppNavigationItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            for (final item in AppNavigationItem.values)
              Expanded(
                child: _NavigationItem(
                  item: item,
                  selected: item == selectedItem,
                  onPressed: () => onItemSelected(item),
                ),
              ),
          ],
        ),
      ),
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

    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 22,
            color: selected ? colorScheme.primary : colorScheme.onSurface,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.label(context)),
        ],
      ),
    );
  }
}
