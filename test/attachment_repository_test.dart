import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:drift/native.dart';

void main() {
  test('Attachment metadata stored with pending_upload', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db.into(db.attachments).insert(
      AttachmentsCompanion.insert(
        id: 'att-1',
        jobId: 'job-1',
        filePath: 'dummy/path.txt',
        mimeType: 'text/plain',
        fileSizeBytes: 12,
        fileHash: 'hash',
        createdAt: DateTime.now(),
        syncStatus: 'pending_upload',
      ),
    );

    final rows = await db.select(db.attachments).get();
    expect(rows.length, 1);
    expect(rows.first.syncStatus, 'pending_upload');

    await db.close();
  });
}
