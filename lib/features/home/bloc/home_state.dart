part of 'home_bloc.dart';

class HomeState {
  const HomeState({
    this.recentDocuments = const [],
    this.isOpening = false,
    this.openToken = 0,
  });

  final List<RecentDocument> recentDocuments;
  final bool isOpening;

  /// Bumped on every successful open so the page can navigate once.
  final int openToken;

  HomeState copyWith({
    List<RecentDocument>? recentDocuments,
    bool? isOpening,
    int? openToken,
  }) {
    return HomeState(
      recentDocuments: recentDocuments ?? this.recentDocuments,
      isOpening: isOpening ?? this.isOpening,
      openToken: openToken ?? this.openToken,
    );
  }

  @override
  bool operator ==(covariant HomeState other) {
    if (identical(this, other)) return true;

    return listEquals(other.recentDocuments, recentDocuments) &&
        other.isOpening == isOpening &&
        other.openToken == openToken;
  }

  @override
  int get hashCode =>
      recentDocuments.hashCode ^ isOpening.hashCode ^ openToken.hashCode;
}
