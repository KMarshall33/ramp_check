import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:ramp_check/data/local/app_database.dart';

class SyncResult {
  SyncResult({
    required this.syncedJobs,
    required this.syncedAttachments,
    required this.durationMs,
  });

  final int syncedJobs;
  final int syncedAttachments;
  final int durationMs;
}

class SyncService {
  SyncService({
    required this.db,
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : client = httpClient ?? http.Client();

  final AppDatabase db;
  final String baseUrl;
  final String apiKey;
  final http.Client client;

  Future<SyncResult> runSync() async {
    final start = DateTime.now();

    final pendingJobs = 
        await (db.select(db.jobs)..where((t) => t.syncStatus.isNotValue('synced'))).get();
    
    final pendingAttachments = 
        await (db.select(db.attachments)..where((t) => t.syncStatus.equals('pending_upload'))).get();

    // ignore: avoid_print
    print('Sync start jobs=${pendingJobs.length} attachments=${pendingAttachments.length}');

    int syncedJobs = 0;
    int syncedAttachments = 0;

    // --- Jobs ---
    if (pendingJobs.isNotEmpty) {
      final payload = {
        'jobs': pendingJobs.map((j) => {
          'client_id': j.id,
          'aircraft_ref': j.aircraftRef,
          'location': j.location,
          'status': j.status,
          'created_at': j.createdAt.toUtc().toIso8601String(),
          'last_modified_at': j.lastModifiedAt.toUtc().toIso8601String(),
        }).toList()
      };

      final res = await client.post(
        Uri.parse('$baseUrl/api/v1/sync/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final results = (decoded['results'] as List).cast<Map<String, dynamic>>();

        for (final r in results) {
          final clientId = r['client_id'] as String;
          final serverId = r['server_id'].toString();

          await (db.update(db.jobs)..where((t) => t.id.equals(clientId))).write(
            JobsCompanion(
              syncStatus: const Value('synced'),
              serverId: Value(serverId),
            ),
          );

          syncedJobs++;
        }
      } else {
        // ignore: avoid_print
        print('Job sync failed status=${res.statusCode} body=${res.body}');
        for (final j in pendingJobs) {
          await (db.update(db.jobs)..where((t) => t.id.equals(j.id))).write(
            const JobsCompanion(syncStatus: Value('failed')),
          );
        }
      }
    }

    // --- Attachment metadata ---
    if (pendingAttachments.isNotEmpty) {
      final payload = {
        'attachments': pendingAttachments.map((a) => {
          'client_id': a.id,
          'job_client_id': a.jobId,
          'file_hash': a.fileHash,
          'mime_type': a.mimeType,
          'file_size_bytes': a.fileSizeBytes,
          'created_at': a.createdAt.toUtc().toIso8601String(),
        }).toList()
      };

      final res = await client.post(
        Uri.parse('$baseUrl/api/v1/sync/attachments'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final results = (decoded['results'] as List).cast<Map<String, dynamic>>();

        for (final r in results) {
          final clientId = r['client_id'] as String;

          await (db.update(db.attachments)..where((t) => t.id.equals(clientId))).write(
            const AttachmentsCompanion(syncStatus: Value('uploaded')),
          );

          syncedAttachments++;
        }
      } else {
        // ignore: avoid_print
        print('Attachment sync failed status=${res.statusCode} body=${res.body}');
        for (final a in pendingAttachments) {
          await (db.update(db.attachments)..where((t) => t.id.equals(a.id))).write(
            const AttachmentsCompanion(syncStatus: Value('failed')),
          );
        }
      }
    }

    final durationMs = DateTime.now().difference(start).inMilliseconds;
    // ignore: avoid_print
    print('Sync end jobs=$syncedJobs attachments=$syncedAttachments duration_ms=$durationMs');

    return SyncResult(
      syncedJobs: syncedJobs,
      syncedAttachments: syncedAttachments,
      durationMs: durationMs,
    );
  }
}
