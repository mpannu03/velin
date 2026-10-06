import 'package:drift/drift.dart';
import 'package:velin/core/recent/recent_document.dart';
import 'package:velin/core/recent/recent_document_repository.dart';

import 'recent_database.dart';

class DriftRecentDocumentRepository implements RecentDocumentRepository {
  DriftRecentDocumentRepository(this._database);

  final RecentDatabase _database;

  @override
  Stream<List<RecentDocument>> watchRecent({int limit = 10}) {
    final query = _database.select(_database.recentDocumentsTable)
      ..orderBy([(table) => OrderingTerm.desc(table.lastOpenedAt)])
      ..limit(limit);

    return query.watch().map(
      (rows) => rows.map(_mapToRecentDocument).toList(growable: false),
    );
  }

  @override
  Stream<RecentDocument?> watch(String path) {
    final query = _database.select(_database.recentDocumentsTable)
      ..where((table) => table.path.equals(path));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapToRecentDocument(row),
    );
  }

  @override
  Future<RecentDocument?> get(String path) async {
    final query = _database.select(_database.recentDocumentsTable)
      ..where((table) => table.path.equals(path));

    final row = await query.getSingleOrNull();

    return row == null ? null : _mapToRecentDocument(row);
  }

  @override
  Future<void> save(RecentDocument document) {
    return _database
        .into(_database.recentDocumentsTable)
        .insertOnConflictUpdate(
          RecentDocumentsTableCompanion.insert(
            path: document.path,
            pageCount: document.pageCount,
            currentPage: document.currentPage,
            lastOpenedAt: document.lastOpenedAt,
          ),
        );
  }

  @override
  Future<void> updateCurrentPage(String path, int currentPage) {
    return (_database.update(_database.recentDocumentsTable)
          ..where((table) => table.path.equals(path)))
        .write(RecentDocumentsTableCompanion(currentPage: Value(currentPage)));
  }

  @override
  Future<void> remove(String path) {
    return (_database.delete(
      _database.recentDocumentsTable,
    )..where((table) => table.path.equals(path))).go();
  }

  @override
  Future<void> clear() {
    return _database.delete(_database.recentDocumentsTable).go();
  }

  RecentDocument _mapToRecentDocument(RecentDocumentsTableData row) {
    return RecentDocument(
      path: row.path,
      pageCount: row.pageCount,
      currentPage: row.currentPage,
      lastOpenedAt: row.lastOpenedAt,
    );
  }
}
