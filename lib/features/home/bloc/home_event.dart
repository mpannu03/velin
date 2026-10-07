part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeRecentDocumentSelected extends HomeEvent {
  const HomeRecentDocumentSelected(this.recentDocument);

  final RecentDocument recentDocument;
}
