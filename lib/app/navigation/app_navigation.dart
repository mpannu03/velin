import 'package:material_ui/material_ui.dart';

enum AppNavigationItem {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    route: '/',
  ),
  reader(
    label: 'Reader',
    icon: Icons.menu_book_outlined,
    route: '/reader',
  ),
  edit(
    label: 'Edit',
    icon: Icons.edit_outlined,
    route: '/edit',
  ),
  tools(
    label: 'Tools',
    icon: Icons.build_outlined,
    route: '/tools',
  );

  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}