import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velin/core/document/document.dart';

import 'recent_documents_table.dart';

part 'recent_database.g.dart';

@DriftDatabase(tables: [RecentDocumentsTable])
class RecentDatabase extends _$RecentDatabase {
  RecentDatabase()
    : super(
        driftDatabase(
          name: 'velin',
          native: DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
        ),
      );

  @override
  int get schemaVersion => 1;
}
