import 'package:ramp_check/core/file_storage_service.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

class AttachmentRepository {
  AttachmentRepository(this.db, this.storage);

  final AppDatabase db;
  final FileStorageService storage;
  final _uuid = const Uuid();

  Stream<List<Attachment>> watchForJob(String jobId) {
    return (db.select(db.attachments)..where((a) => a.jobId.equals(jobId))).watch();
  }

  Future<void> addForJob({
    required String jobId,
    required String sourcePath,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final stored = await storage.storeJobAttachment(
      jobId: jobId,
      sourcePath: sourcePath,
    );

    await db.into(db.attachments).insert(
      AttachmentsCompanion.insert(
        id: id,
        jobId: jobId,
        filePath: stored.storedPath,
        mimeType: stored.mimeType,
        fileSizeBytes: stored.fileSizeBytes,
        fileHash: stored.sha256Hex,
        createdAt: now,
        syncStatus: 'pending_upload',
      ),
    );

    await db.into(db.auditLogs).insert(
      AuditLogsCompanion.insert(
        timestamp: now,
        action: 'create',
        entityType: 'attachment',
        entityId: id,
      ),
    );

    // ignore: avoid_print
    print('Attachment added'
      'jobId=$jobId '
      'id=$id '
      'path=${stored.storedPath} '
      'hash=${stored.sha256Hex} '
      'status=pending_upload',
    );
  }
}
