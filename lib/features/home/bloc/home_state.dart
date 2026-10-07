part of 'home_bloc.dart';

class HomeState {
  HomeState({this.recentDocuments = const []});

  final List<RecentDocument> recentDocuments;

  @override
  bool operator ==(covariant HomeState other) {
    if (identical(this, other)) return true;

    return listEquals(other.recentDocuments, recentDocuments);
  }

  @override
  int get hashCode => recentDocuments.hashCode;
}
