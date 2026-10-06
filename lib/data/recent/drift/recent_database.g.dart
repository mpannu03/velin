// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_database.dart';

// ignore_for_file: type=lint
class $RecentDocumentsTableTable extends RecentDocumentsTable
    with TableInfo<$RecentDocumentsTableTable, RecentDocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentDocumentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    path,
    pageCount,
    currentPage,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_documents_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentDocumentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentPageMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  RecentDocumentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentDocumentsTableData(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $RecentDocumentsTableTable createAlias(String alias) {
    return $RecentDocumentsTableTable(attachedDatabase, alias);
  }
}

class RecentDocumentsTableData extends DataClass
    implements Insertable<RecentDocumentsTableData> {
  final String path;
  final int pageCount;
  final int currentPage;
  final DateTime lastOpenedAt;
  const RecentDocumentsTableData({
    required this.path,
    required this.pageCount,
    required this.currentPage,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['page_count'] = Variable<int>(pageCount);
    map['current_page'] = Variable<int>(currentPage);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  RecentDocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return RecentDocumentsTableCompanion(
      path: Value(path),
      pageCount: Value(pageCount),
      currentPage: Value(currentPage),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory RecentDocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentDocumentsTableData(
      path: serializer.fromJson<String>(json['path']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'pageCount': serializer.toJson<int>(pageCount),
      'currentPage': serializer.toJson<int>(currentPage),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  RecentDocumentsTableData copyWith({
    String? path,
    int? pageCount,
    int? currentPage,
    DateTime? lastOpenedAt,
  }) => RecentDocumentsTableData(
    path: path ?? this.path,
    pageCount: pageCount ?? this.pageCount,
    currentPage: currentPage ?? this.currentPage,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  RecentDocumentsTableData copyWithCompanion(
    RecentDocumentsTableCompanion data,
  ) {
    return RecentDocumentsTableData(
      path: data.path.present ? data.path.value : this.path,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentDocumentsTableData(')
          ..write('path: $path, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, pageCount, currentPage, lastOpenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentDocumentsTableData &&
          other.path == this.path &&
          other.pageCount == this.pageCount &&
          other.currentPage == this.currentPage &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class RecentDocumentsTableCompanion
    extends UpdateCompanion<RecentDocumentsTableData> {
  final Value<String> path;
  final Value<int> pageCount;
  final Value<int> currentPage;
  final Value<DateTime> lastOpenedAt;
  final Value<int> rowid;
  const RecentDocumentsTableCompanion({
    this.path = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentDocumentsTableCompanion.insert({
    required String path,
    required int pageCount,
    required int currentPage,
    required DateTime lastOpenedAt,
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       pageCount = Value(pageCount),
       currentPage = Value(currentPage),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<RecentDocumentsTableData> custom({
    Expression<String>? path,
    Expression<int>? pageCount,
    Expression<int>? currentPage,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (pageCount != null) 'page_count': pageCount,
      if (currentPage != null) 'current_page': currentPage,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentDocumentsTableCompanion copyWith({
    Value<String>? path,
    Value<int>? pageCount,
    Value<int>? currentPage,
    Value<DateTime>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return RecentDocumentsTableCompanion(
      path: path ?? this.path,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentDocumentsTableCompanion(')
          ..write('path: $path, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$RecentDatabase extends GeneratedDatabase {
  _$RecentDatabase(QueryExecutor e) : super(e);
  $RecentDatabaseManager get managers => $RecentDatabaseManager(this);
  late final $RecentDocumentsTableTable recentDocumentsTable =
      $RecentDocumentsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recentDocumentsTable];
}

typedef $$RecentDocumentsTableTableCreateCompanionBuilder =
    RecentDocumentsTableCompanion Function({
      required String path,
      required int pageCount,
      required int currentPage,
      required DateTime lastOpenedAt,
      Value<int> rowid,
    });
typedef $$RecentDocumentsTableTableUpdateCompanionBuilder =
    RecentDocumentsTableCompanion Function({
      Value<String> path,
      Value<int> pageCount,
      Value<int> currentPage,
      Value<DateTime> lastOpenedAt,
      Value<int> rowid,
    });

class $$RecentDocumentsTableTableFilterComposer
    extends Composer<_$RecentDatabase, $RecentDocumentsTableTable> {
  $$RecentDocumentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentDocumentsTableTableOrderingComposer
    extends Composer<_$RecentDatabase, $RecentDocumentsTableTable> {
  $$RecentDocumentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentDocumentsTableTableAnnotationComposer
    extends Composer<_$RecentDatabase, $RecentDocumentsTableTable> {
  $$RecentDocumentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );
}

class $$RecentDocumentsTableTableTableManager
    extends
        RootTableManager<
          _$RecentDatabase,
          $RecentDocumentsTableTable,
          RecentDocumentsTableData,
          $$RecentDocumentsTableTableFilterComposer,
          $$RecentDocumentsTableTableOrderingComposer,
          $$RecentDocumentsTableTableAnnotationComposer,
          $$RecentDocumentsTableTableCreateCompanionBuilder,
          $$RecentDocumentsTableTableUpdateCompanionBuilder,
          (
            RecentDocumentsTableData,
            BaseReferences<
              _$RecentDatabase,
              $RecentDocumentsTableTable,
              RecentDocumentsTableData
            >,
          ),
          RecentDocumentsTableData,
          PrefetchHooks Function()
        > {
  $$RecentDocumentsTableTableTableManager(
    _$RecentDatabase db,
    $RecentDocumentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentDocumentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentDocumentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecentDocumentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> path = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentDocumentsTableCompanion(
                path: path,
                pageCount: pageCount,
                currentPage: currentPage,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String path,
                required int pageCount,
                required int currentPage,
                required DateTime lastOpenedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentDocumentsTableCompanion.insert(
                path: path,
                pageCount: pageCount,
                currentPage: currentPage,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecentDocumentsTableTable,
                    RecentDocumentsTableData
                  >(table),
                  BaseReferences<
                    _$RecentDatabase,
                    $RecentDocumentsTableTable,
                    RecentDocumentsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentDocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$RecentDatabase,
      $RecentDocumentsTableTable,
      RecentDocumentsTableData,
      $$RecentDocumentsTableTableFilterComposer,
      $$RecentDocumentsTableTableOrderingComposer,
      $$RecentDocumentsTableTableAnnotationComposer,
      $$RecentDocumentsTableTableCreateCompanionBuilder,
      $$RecentDocumentsTableTableUpdateCompanionBuilder,
      (
        RecentDocumentsTableData,
        BaseReferences<
          _$RecentDatabase,
          $RecentDocumentsTableTable,
          RecentDocumentsTableData
        >,
      ),
      RecentDocumentsTableData,
      PrefetchHooks Function()
    >;

class $RecentDatabaseManager {
  final _$RecentDatabase _db;
  $RecentDatabaseManager(this._db);
  $$RecentDocumentsTableTableTableManager get recentDocumentsTable =>
      $$RecentDocumentsTableTableTableManager(_db, _db.recentDocumentsTable);
}
