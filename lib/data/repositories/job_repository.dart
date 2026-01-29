import 'package:ramp_check/data/local/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';


class JobRepository {
  JobRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  Stream<List<Job>> watchJobs() {
    return (db.select(db.jobs)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<void> createJob({
    required String aircraftRef,
    required String location,
    String status = 'open',
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await db.into(db.jobs).insert(
      JobsCompanion.insert(
        id: id,
        aircraftRef: aircraftRef,
        location: location,
        status: status,
        createdAt: now,
        lastModifiedAt: now,
        syncStatus: 'pending',
        serverId: const Value(null),
      ),
    );

    // Minimal audit record (helps later for GDPR accountability evidence)
    await db.into(db.auditLogs).insert(
      AuditLogsCompanion.insert(
        timestamp: now,
        action: 'create',
        entityType: 'job',
        entityId: id,
      ),
    );
  }
}
