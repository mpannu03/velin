import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/commands/commands.dart';
import 'package:velin/app/shell/widgets/widgets.dart';
import 'package:velin/core/app_info/app_info.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockAppCommandHandler extends Mock implements AppCommandHandler {}

void main() {
  late MockAppCommandHandler handler;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    handler = MockAppCommandHandler();
    navigatorKey = GlobalKey<NavigatorState>();

    when(() => handler.openDocument()).thenAnswer((_) async {});
    when(() => handler.toggleFullScreen()).thenAnswer((_) async {});
    when(() => handler.openLogsFolder()).thenAnswer((_) async {});
    when(() => handler.quit()).thenAnswer((_) async {});
  });

  Future<void> pumpScope(WidgetTester tester, {Widget? body}) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => AppCommandScope(
          handler: handler,
          appInfo: const AppInfo(version: '1.2.3', buildNumber: '4'),
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: Scaffold(body: body ?? const TextField(autofocus: true)),
      ),
    );
    await tester.pump();
  }

  Future<void> pressWithControl(
    WidgetTester tester,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  }

  group('shortcuts', () {
    testWidgets('Ctrl+O opens a document, even from a text field', (
      tester,
    ) async {
      await pumpScope(tester);

      await pressWithControl(tester, LogicalKeyboardKey.keyO);

      verify(() => handler.openDocument()).called(1);
    });

    testWidgets('F11 toggles full screen', (tester) async {
      await pumpScope(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.f11);

      verify(() => handler.toggleFullScreen()).called(1);
    });

    testWidgets('Ctrl+Q quits', (tester) async {
      await pumpScope(tester);

      await pressWithControl(tester, LogicalKeyboardKey.keyQ);

      verify(() => handler.quit()).called(1);
    });
  });

  group('AppMenuButton', () {
    Future<void> openMenu(WidgetTester tester) async {
      await pumpScope(tester, body: const AppMenuButton());
      await tester.tap(find.byType(AppMenuButton));
      await tester.pumpAndSettle();
    }

    testWidgets('lists every command with its shortcut', (tester) async {
      await openMenu(tester);

      expect(find.text('Open…'), findsOneWidget);
      expect(find.text('Full screen'), findsOneWidget);
      expect(find.text('Open logs folder'), findsOneWidget);
      expect(find.text('About Velin'), findsOneWidget);
      expect(find.text('Quit'), findsOneWidget);
      expect(find.text('Ctrl+O'), findsOneWidget);
      expect(find.text('F11'), findsOneWidget);
    });

    testWidgets('runs the chosen command', (tester) async {
      await openMenu(tester);

      await tester.tap(find.text('Open logs folder'));
      await tester.pumpAndSettle();

      verify(() => handler.openLogsFolder()).called(1);
    });

    testWidgets('About shows the version and license', (tester) async {
      await openMenu(tester);

      await tester.tap(find.text('About Velin'));
      await tester.pumpAndSettle();

      expect(find.text('1.2.3 (4)'), findsOneWidget);
      expect(
        find.textContaining('GNU Affero General Public License'),
        findsOneWidget,
      );
    });
  });
}
