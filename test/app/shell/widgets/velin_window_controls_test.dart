import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/shell/widgets/widgets.dart';
import 'package:window_manager/window_manager.dart';

class MockWindowManager extends Mock implements WindowManager {}

void main() {
  late MockWindowManager windowManager;

  setUp(() {
    windowManager = MockWindowManager();
  });

  testWidgets('renders window controls', (tester) async {
    when(
      () => windowManager.isMaximized()
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(
      MaterialApp(
        home: VelinWindowControls(
          windowManager: windowManager,
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.crop_square), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('minimize button minimizes window', (tester) async {
    when(
      () => windowManager.isMaximized()
    ).thenAnswer((_) async => false);

    when(
      () => windowManager.minimize()
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: VelinWindowControls(
          windowManager: windowManager,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));

    verify(() => windowManager.minimize()).called(1);
  });

  testWidgets('close button closes window', (tester) async {
    when(
      () => windowManager.isMaximized()
    ).thenAnswer((_) async => false);

    when(
      () => windowManager.close()
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: VelinWindowControls(
          windowManager: windowManager,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));

    verify(() => windowManager.close()).called(1);
  });

  testWidgets('maximize button maximizes window when not maximized',
      (tester) async {
    when(
      () => windowManager.isMaximized()
    ).thenAnswer((_) async => false);
    when(
      () => windowManager.maximize()
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: VelinWindowControls(
          windowManager: windowManager,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pump();

    verify(() => windowManager.maximize()).called(1);
  });

  testWidgets('resize button restores window when maximized', (tester) async {
    when(
      () => windowManager.isMaximized()
    ).thenAnswer((_) async => true);
    when(
      () => windowManager.restore()
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: VelinWindowControls(
          windowManager: windowManager,
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.byIcon(Icons.filter_none));
    await tester.pump();

    verify(() => windowManager.restore()).called(1);
  });
}