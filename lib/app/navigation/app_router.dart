import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/navigation/navigation.dart';
import 'package:velin/app/shell/app_shell.dart';
import 'package:velin/core/platform/platform.dart';
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
            child: AppNavigationShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Home'),
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
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Edit'),
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
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const MergePdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'split-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const SplitPdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'extract-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const ExtractPdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'rotate-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const RotatePdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'pdf-to-image',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const PdfToImagePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'image-to-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const ImageToPdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'protect-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const EncryptPdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'unlock-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const DecryptPdfPage(),
                    ),
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

Page<void> _toolPage({required LocalKey key, required Widget child}) {
  if (appPlatform == AppPlatform.desktop) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
  return MaterialPage(key: key, child: child);
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
