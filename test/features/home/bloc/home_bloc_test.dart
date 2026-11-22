import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/error/app_failure.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/features/home/home.dart';

class MockRecentDocumentService extends Mock implements RecentDocumentService {}

class MockDocumentService extends Mock implements DocumentService {}

class MockAppEffectController extends Mock implements AppEffectController {}

void main() {
  late MockRecentDocumentService recentDocumentService;
  late MockDocumentService documentService;
  late MockAppEffectController appEffectController;
  late StreamController<Result<List<RecentDocument>>> recents;

  final recent = RecentDocument(
    path: '/docs/report.pdf',
    pageCount: 12,
    currentPage: 3,
    lastOpenedAt: DateTime(2026, 11, 1),
    documentType: DocumentType.pdf,
  );
  final document = Document(path: '/docs/report.pdf', type: DocumentType.pdf);
  const failure = FileNotFoundFailure(path: '/docs/report.pdf');

  HomeBloc buildBloc() => HomeBloc(
    recentDocumentService: recentDocumentService,
    documentService: documentService,
    appEffectController: appEffectController,
  );

  setUpAll(() {
    registerFallbackValue(recent);
    registerFallbackValue(failure);
  });

  setUp(() {
    recentDocumentService = MockRecentDocumentService();
    documentService = MockDocumentService();
    appEffectController = MockAppEffectController();
    recents = StreamController.broadcast();

    when(() => recentDocumentService.watchRecent(limit: any(named: 'limit')))
        .thenAnswer((_) => recents.stream);
  });

  tearDown(() => recents.close());

  group('HomeStarted', () {
    blocTest<HomeBloc, HomeState>(
      'watches up to recentLimit documents',
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeStarted()),
      verify: (_) {
        verify(
          () => recentDocumentService.watchRecent(limit: HomeBloc.recentLimit),
        ).called(1);
        expect(HomeBloc.recentLimit, 100);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'shows the recent documents as they arrive',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await Future<void>.delayed(Duration.zero);
        recents.add(Success([recent]));
      },
      expect: () => [
        HomeState(recentDocuments: [recent]),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'keeps the last known list when loading fails',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await Future<void>.delayed(Duration.zero);
        recents.add(Success([recent]));
        await Future<void>.delayed(Duration.zero);
        recents.add(const Failure(failure));
      },
      expect: () => [
        HomeState(recentDocuments: [recent]),
      ],
    );
  });

  group('HomeRecentDocumentSelected', () {
    blocTest<HomeBloc, HomeState>(
      'opens the document and asks the page to navigate',
      build: buildBloc,
      setUp: () =>
          when(() => documentService.openRecent(any()))
              .thenAnswer((_) async => Success(document)),
      act: (bloc) => bloc.add(HomeRecentDocumentSelected(recent)),
      expect: () => const [HomeState(isOpening: true), HomeState(openToken: 1)],
    );

    blocTest<HomeBloc, HomeState>(
      'reports a failure and stays on Home',
      build: buildBloc,
      setUp: () =>
          when(() => documentService.openRecent(any()))
              .thenAnswer((_) async => const Failure(failure)),
      act: (bloc) => bloc.add(HomeRecentDocumentSelected(recent)),
      expect: () => const [HomeState(isOpening: true), HomeState()],
      verify: (_) =>
          verify(() => appEffectController.notifyFailure(failure)).called(1),
    );
  });

  group('HomeOpenRequested', () {
    blocTest<HomeBloc, HomeState>(
      'opens the picked document and asks the page to navigate',
      build: buildBloc,
      setUp: () =>
          when(() => documentService.open())
              .thenAnswer((_) async => Success(document)),
      act: (bloc) => bloc.add(const HomeOpenRequested()),
      expect: () => const [HomeState(isOpening: true), HomeState(openToken: 1)],
    );

    blocTest<HomeBloc, HomeState>(
      'does nothing more when the picker is cancelled',
      build: buildBloc,
      setUp: () =>
          when(() => documentService.open())
              .thenAnswer((_) async => const Success(null)),
      act: (bloc) => bloc.add(const HomeOpenRequested()),
      expect: () => const [HomeState(isOpening: true), HomeState()],
    );

    blocTest<HomeBloc, HomeState>(
      'reports a failure',
      build: buildBloc,
      setUp: () =>
          when(() => documentService.open())
              .thenAnswer((_) async => const Failure(failure)),
      act: (bloc) => bloc.add(const HomeOpenRequested()),
      expect: () => const [HomeState(isOpening: true), HomeState()],
      verify: (_) =>
          verify(() => appEffectController.notifyFailure(failure)).called(1),
    );

    blocTest<HomeBloc, HomeState>(
      'ignores a second request while a file is opening',
      build: buildBloc,
      seed: () => const HomeState(isOpening: true),
      act: (bloc) => bloc.add(const HomeOpenRequested()),
      expect: () => const <HomeState>[],
      verify: (_) => verifyNever(() => documentService.open()),
    );
  });
}
