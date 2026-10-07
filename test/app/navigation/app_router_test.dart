import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/navigation/app_router.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/home/home.dart';
import 'package:velin/features/reader/reader.dart';
import 'package:velin/l10n/app_localizations.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

void main() {
  late MockReaderBloc readerBloc;
  late MockHomeBloc homeBloc;

  setUp(() {
    readerBloc = MockReaderBloc();
    homeBloc = MockHomeBloc();
    when(() => readerBloc.state).thenReturn(ReaderLoaded.empty());
    when(() => homeBloc.state).thenReturn(HomeState());
    // when(() => readerBloc.stream).thenAnswer((_) => const Stream.empty());
    // when(() => readerBloc.close()).thenAnswer((_) async {});
    getIt.registerSingleton<ReaderBloc>(readerBloc);
    getIt.registerSingleton<HomeBloc>(homeBloc);
  });

  tearDown(() async => getIt.reset());

  group('AppRouter', () {
    testWidgets('opens Home at the initial location', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      expect(AppRouter.router.state.uri.path, '/');
    });

    testWidgets('navigates between application sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
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
