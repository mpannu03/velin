import 'recent_document.dart';

abstract interface class RecentDocumentRepository {
  Stream<List<RecentDocument>> watchRecent({int limit = 10});

  Stream<RecentDocument?> watch(String path);

  Future<RecentDocument?> get(String path);

  Future<void> save(RecentDocument document);

  Future<void> updateCurrentPage(String path, int currentPage);

  Future<void> remove(String path);

  Future<void> clear();
}
