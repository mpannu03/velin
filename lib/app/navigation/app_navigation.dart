import 'package:material_ui/material_ui.dart';

enum AppNavigationItem {
  home(
    icon: Icons.home_outlined,
    route: '/',
  ),
  reader(
    icon: Icons.menu_book_outlined,
    route: '/reader',
  ),
  edit(
    icon: Icons.edit_outlined,
    route: '/edit',
  ),
  tools(
    icon: Icons.build_outlined,
    route: '/tools',
  );

  const AppNavigationItem({
    required this.icon,
    required this.route,
  });

  final IconData icon;
  final String route;
}