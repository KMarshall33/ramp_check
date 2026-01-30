import 'dart:convert';

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:ramp_check/sync/sync_service.dart';

void main() {
  test('SyncService updates statuses on success', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Seed pending job and attachment
    await db.into(db.jobs).insert(
      JobsCompanion.insert(
        id: 'job-1',
        aircraftRef: 'G-TEST',
        location: 'Bay 1',
        status: 'open',
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
        syncStatus: 'pending',
        serverId: const Value(null),
      ),
    );

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

    final client = MockClient((req) async {
      if (req.url.path.endsWith('/api/v1/sync/jobs')) {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect((body['jobs'] as List).length, 1);
        return http.Response(
          jsonEncode({
            'results': [
              {'client_id': 'job-1', 'server_id': 1, 'status': 'synced'}
            ]
          }),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (req.url.path.endsWith('/api/v1/sync/attachments')) {
        return http.Response(
          jsonEncode({
            'results': [
              {'client_id': 'att-1', 'status': 'uploaded'}
            ]
          }),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }

      return http.Response('Not found', 404);
    });

    final service = SyncService(
      db: db,
      baseUrl: 'http://127.0.0.1:5000',
      apiKey: 'key',
      httpClient: client,
    );

    await service.runSync();

    final jobs = await db.select(db.jobs).get();
    expect(jobs.first.syncStatus, 'synced');
    expect(jobs.first.serverId, '1');

    final atts = await db.select(db.attachments).get();
    expect(atts.first.syncStatus, 'uploaded');

    await db.close();
  });
}
