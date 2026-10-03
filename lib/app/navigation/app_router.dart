import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/navigation/navigation.dart';
import 'package:velin/app/shell/app_shell.dart';
import 'package:velin/features/reader/reader.dart';
import 'package:velin/features/tools/tools.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            child: AppNavigationShell(
              navigationShell: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const _PlaceholderPage(
                  title: 'Home',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reader',
                builder: (context, state) => const ReaderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/edit',
                builder: (context, state) => const _PlaceholderPage(
                  title: 'Edit',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolsPage(),
                routes: [
                  GoRoute(
                    path: 'merge-pdf',
                    builder: (context, state) => const MergePdfPage(),
                  ),
                  GoRoute(
                    path: 'split-pdf',
                    builder: (context, state) => const SplitPdfPage(),
                  ),
                  GoRoute(
                    path: 'extract-pdf',
                    builder: (context, state) => const ExtractPdfPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title),
    );
  }
}