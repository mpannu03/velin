import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/core/platform/platform.dart';

import 'app_navigation.dart';
import 'desktop_navigation.dart';
import 'mobile_navigation.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selectedItem =
        AppNavigationItem.values[navigationShell.currentIndex];

    return switch (appPlatform) {
      AppPlatform.desktop => Column(
          children: [
            DesktopNavigation(
              selectedItem: selectedItem,
              onItemSelected: _onItemSelected,
            ),
            Expanded(
              child: navigationShell,
            ),
          ],
        ),
      AppPlatform.mobile => Column(
          children: [
            Expanded(
              child: navigationShell,
            ),
            MobileNavigation(
              selectedItem: selectedItem,
              onItemSelected: _onItemSelected,
            ),
          ],
        ),
    };
  }

  void _onItemSelected(AppNavigationItem item) {
    navigationShell.goBranch(
      item.index,
      initialLocation: item.index == navigationShell.currentIndex,
    );
  }
}