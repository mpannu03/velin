import 'package:drift/drift.dart';

class RecentDocumentsTable extends Table {
  TextColumn get path => text()();

  IntColumn get pageCount => integer()();

  IntColumn get currentPage => integer()();

  DateTimeColumn get lastOpenedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {path};
}
