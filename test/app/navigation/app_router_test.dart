import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import 'package:velin/app/navigation/app_router.dart';
import 'package:velin/features/reader/reader.dart';

class MockReaderBloc extends Mock implements ReaderBloc {}

void main() {

  late MockReaderBloc mockBloc;

  setUp(() {
    mockBloc = MockReaderBloc();
    when(() => mockBloc.state).thenReturn(ReaderLoaded.empty());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
    GetIt.instance.registerSingleton<ReaderBloc>(mockBloc);
  });

  tearDown(() async => GetIt.instance.reset());

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