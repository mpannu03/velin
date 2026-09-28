import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_navigation_shell.dart';

void main() {
  testWidgets('shows desktop navigation and current branch content', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              body: AppNavigationShell(
                navigationShell: navigationShell,
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => const Text('Home content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/reader',
                  builder: (_, _) => const Text('Reader content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/edit',
                  builder: (_, _) => const Text('Edit content'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tools',
                  builder: (_, _) => const Text('Tools content'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Home content'), findsOneWidget);

    await tester.tap(find.text('Reader'));
    await tester.pumpAndSettle();

    expect(find.text('Reader'), findsOneWidget);
    expect(find.text('Reader content'), findsOneWidget);

    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();

    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Tools content'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Edit content'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Home content'), findsOneWidget);
  });
}