import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/window/window_placement.dart';
import 'package:window_manager/window_manager.dart';

class MockWindowManager extends Mock implements WindowManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(Rect.zero);
  });

  const placement = WindowPlacement(
    bounds: Rect.fromLTWH(100, 80, 1200, 800),
    isMaximized: true,
  );

  const screen = Rect.fromLTWH(0, 0, 1920, 1040);

  group('WindowPlacement', () {
    test('round-trips through JSON', () {
      expect(WindowPlacement.fromJson(placement.toJson()), placement);
    });

    test('rejects malformed data', () {
      expect(WindowPlacement.fromJson(null), isNull);
      expect(WindowPlacement.fromJson('nope'), isNull);
      expect(WindowPlacement.fromJson({'x': 1, 'y': 2}), isNull);
      expect(
        WindowPlacement.fromJson({'x': 0, 'y': 0, 'width': 0, 'height': 10}),
        isNull,
      );
    });

    test('is visible when enough of it is on a display', () {
      expect(placement.isVisibleOn([screen]), isTrue);
    });

    test('is not visible when its display is gone', () {
      const onUnpluggedMonitor = WindowPlacement(
        bounds: Rect.fromLTWH(2200, 100, 1200, 800),
        isMaximized: false,
      );

      expect(onUnpluggedMonitor.isVisibleOn([screen]), isFalse);
    });

    test('is not visible when only a sliver is on screen', () {
      const sliver = WindowPlacement(
        bounds: Rect.fromLTWH(1900, 100, 1200, 800),
        isMaximized: false,
      );

      expect(sliver.isVisibleOn([screen]), isFalse);
    });
  });

  group('WindowPlacementStore', () {
    late Directory tempDir;
    late WindowPlacementStore store;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('velin_window_');
      store = WindowPlacementStore(File(p.join(tempDir.path, 'window.json')));
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    test('loads what it saved', () async {
      await store.save(placement);

      expect(await store.load(), placement);
    });

    test('loads nothing when there is no file', () async {
      expect(await store.load(), isNull);
    });

    test('loads nothing from a corrupt file', () async {
      store.file.writeAsStringSync('{not json');

      expect(await store.load(), isNull);
    });
  });

  group('WindowPlacementKeeper', () {
    late Directory tempDir;
    late WindowPlacementStore store;
    late MockWindowManager windowManager;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('velin_window_');
      store = WindowPlacementStore(File(p.join(tempDir.path, 'window.json')));
      windowManager = MockWindowManager();

      when(() => windowManager.setBounds(any())).thenAnswer((_) async {});
      when(() => windowManager.maximize()).thenAnswer((_) async {});
      when(() => windowManager.isMaximized()).thenAnswer((_) async => false);
      when(() => windowManager.isFullScreen()).thenAnswer((_) async => false);
      when(() => windowManager.isMinimized()).thenAnswer((_) async => false);
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    WindowPlacementKeeper buildKeeper({List<Rect> displays = const [screen]}) {
      return WindowPlacementKeeper(
        store: store,
        windowManager: windowManager,
        displays: () async => displays,
        saveDelay: Duration.zero,
      );
    }

    test('restores the saved bounds and maximized state', () async {
      await store.save(placement);

      await buildKeeper().restore();

      verify(() => windowManager.setBounds(placement.bounds)).called(1);
      verify(() => windowManager.maximize()).called(1);
    });

    test(
      'keeps the default placement when the saved one is off-screen',
      () async {
        await store.save(placement);

        await buildKeeper(displays: const [Rect.fromLTWH(-3000, 0, 1920, 1040)])
            .restore();

        verifyNever(() => windowManager.setBounds(any()));
        verifyNever(() => windowManager.maximize());
      },
    );

    test('saves the bounds after the window is moved', () async {
      const moved = Rect.fromLTWH(50, 60, 1000, 700);
      when(() => windowManager.getBounds()).thenAnswer((_) async => moved);

      final keeper = buildKeeper()..onWindowMoved();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        await store.load(),
        const WindowPlacement(bounds: moved, isMaximized: false),
      );
      keeper.dispose();
    });

    test('saves on the continuous move events Linux sends', () async {
      const moved = Rect.fromLTWH(10, 20, 900, 600);
      when(() => windowManager.getBounds()).thenAnswer((_) async => moved);

      final keeper = buildKeeper()
        ..onWindowMove()
        ..onWindowMove()
        ..onWindowResize();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        await store.load(),
        const WindowPlacement(bounds: moved, isMaximized: false),
      );
      verify(() => windowManager.getBounds()).called(1);
      keeper.dispose();
    });

    test('keeps the normal bounds when maximized', () async {
      await store.save(
        const WindowPlacement(bounds: screen, isMaximized: false),
      );
      final keeper = buildKeeper();
      await keeper.restore();

      when(() => windowManager.isMaximized()).thenAnswer((_) async => true);
      keeper.onWindowMaximize();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        await store.load(),
        const WindowPlacement(bounds: screen, isMaximized: true),
      );
      verifyNever(() => windowManager.getBounds());
      keeper.dispose();
    });

    test('does not save full-screen bounds', () async {
      when(() => windowManager.isFullScreen()).thenAnswer((_) async => true);

      final keeper = buildKeeper()..onWindowResized();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await store.load(), isNull);
      keeper.dispose();
    });
  });
}
