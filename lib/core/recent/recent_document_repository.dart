import 'package:velin/core/result/result.dart';

import 'recent_document.dart';

abstract interface class RecentDocumentRepository {
  Stream<Result<List<RecentDocument>>> watchRecent({int limit = 10});

  Stream<Result<RecentDocument>> watch(String path);

  Future<Result<RecentDocument>> get(String path);

  Future<void> save(RecentDocument document);

  Future<void> updateCurrentPage(String path, int currentPage);

  Future<void> remove(String path);

  Future<void> clear();
}
