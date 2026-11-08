import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/navigation/navigation.dart';
import 'package:velin/app/shell/app_shell.dart';
import 'package:velin/core/platform/platform.dart';
import 'package:velin/features/home/home.dart';
import 'package:velin/features/reader/reader.dart';
import 'package:velin/features/tools/tools.dart';

class AppRouter {
  AppRouter._();

  /// Lets app-level overlays (e.g. confirmation dialogs) find a Navigator
  /// from above the router.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    // Development aid: `--dart-define=VELIN_START_ROUTE=/tools/merge-pdf`
    // starts on that page (e.g. for screenshots). Always `/` in releases.
    initialLocation: kReleaseMode
        ? '/'
        : const String.fromEnvironment('VELIN_START_ROUTE', defaultValue: '/'),
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
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
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
                  GoRoute(
                    path: 'compress-pdf',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const CompressPdfPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'watermark',
                    pageBuilder: (context, state) => _toolPage(
                      key: state.pageKey,
                      child: const AddWatermarkPage(),
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
