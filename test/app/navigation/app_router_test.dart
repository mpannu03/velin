import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_router.dart';

void main() {
  group('AppRouter', () {
    testWidgets('opens Home at the initial location', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      expect(AppRouter.router.state.uri.path, '/');
    });

    testWidgets('navigates between application sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Reader'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.uri.path, '/reader');

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.uri.path, '/edit');

      await tester.tap(find.text('Tools'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.uri.path, '/tools');

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.uri.path, '/');
    });
  });
}