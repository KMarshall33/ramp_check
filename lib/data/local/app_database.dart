import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Jobs extends Table {
  TextColumn get id => text()();
  TextColumn get aircraftRef => text()();
  TextColumn get location => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastModifiedAt => dateTime()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InspectionItems extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get title => text()();
  TextColumn get result => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get lastModifiedAt => dateTime()();
  TextColumn get syncStatus => text()();
  TextColumn get serverId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get fileHash => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
}

@DriftDatabase(
  tables: [Jobs, InspectionItems, Attachments, AuditLogs],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase.forTesting(QueryExecutor e) : super(e);
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File dbFile = File(p.join(appDir.path, 'ramp_check.db'));
    return NativeDatabase(dbFile);
  });
}
