part of 'home_bloc.dart';

class HomeState {
  const HomeState({
    this.recentDocuments = const [],
    this.isOpening = false,
    this.openToken = 0,
    this.openFailure,
  });

  final List<RecentDocument> recentDocuments;
  final bool isOpening;

  /// Bumped on every successful open so the page can navigate once.
  final int openToken;
  final Object? openFailure;

  HomeState copyWith({
    List<RecentDocument>? recentDocuments,
    bool? isOpening,
    int? openToken,
    Object? openFailure,
    bool clearOpenFailure = false,
  }) {
    return HomeState(
      recentDocuments: recentDocuments ?? this.recentDocuments,
      isOpening: isOpening ?? this.isOpening,
      openToken: openToken ?? this.openToken,
      openFailure: clearOpenFailure ? null : (openFailure ?? this.openFailure),
    );
  }

  @override
  bool operator ==(covariant HomeState other) {
    if (identical(this, other)) return true;

    return listEquals(other.recentDocuments, recentDocuments) &&
        other.isOpening == isOpening &&
        other.openToken == openToken &&
        other.openFailure == openFailure;
  }

  @override
  int get hashCode =>
      recentDocuments.hashCode ^
      isOpening.hashCode ^
      openToken.hashCode ^
      openFailure.hashCode;
}
