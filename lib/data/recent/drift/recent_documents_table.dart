import 'package:drift/drift.dart';
import 'package:velin/core/document/document.dart';

class RecentDocumentsTable extends Table {
  TextColumn get path => text()();

  IntColumn get pageCount => integer()();

  IntColumn get currentPage => integer()();

  DateTimeColumn get lastOpenedAt => dateTime()();

  IntColumn get documentType => intEnum<DocumentType>()();

  @override
  Set<Column<Object>> get primaryKey => {path};
}
