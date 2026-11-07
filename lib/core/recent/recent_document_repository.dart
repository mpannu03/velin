import 'package:velin/core/result/result.dart';

import 'recent_document.dart';

abstract interface class RecentDocumentRepository {
  Stream<Result<List<RecentDocument>>> watchRecent({int limit = 10});

  /// Emits `Success(null)` while [path] is not in the recent list.
  Stream<Result<RecentDocument?>> watch(String path);

  /// `Success(null)` when [path] is not in the recent list.
  Future<Result<RecentDocument?>> get(String path);

  Future<void> save(RecentDocument document);

  Future<void> updateCurrentPage(String path, int currentPage);

  Future<void> remove(String path);

  Future<void> clear();
}
