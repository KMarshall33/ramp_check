import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ramp_check/core/sync_config.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/sync/connectivity_trigger.dart';
import 'package:ramp_check/ui/job_list_page.dart';
import 'package:ramp_check/data/repositories/attachment_repository.dart';
import 'package:ramp_check/core/file_storage_service.dart';
import 'package:ramp_check/core/api_key_store.dart';
import 'package:ramp_check/sync/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final jobRepo = JobRepository(db);
  final attachmentRepo = AttachmentRepository(
    db, 
    FileStorageService()
  );

  final baseUrl = Platform.isAndroid
      ? SyncConfig.androidEmulatorBaseUrl
      : SyncConfig.windowsBaseUrl;

  const storage = FlutterSecureStorage();
  final keyStore = ApiKeyStore(storage);

  final existingKey = await keyStore.getApiKey();
  if (existingKey == null || existingKey.isEmpty) {
    await keyStore.setApiKey('api_warehouse_student_key_1234567890abcdef');
  }
  final apiKey = await keyStore.getApiKey();

  final syncService = SyncService(
    db: db,
    baseUrl: baseUrl,
    apiKey: apiKey ?? '',
  );

  final trigger = ConnectivityTrigger(syncService);
  trigger.start();

  runApp(RampCheckApp(
    jobRepo: jobRepo, 
    attachmentRepo: attachmentRepo,
    syncService: syncService,
  ));
}

class RampCheckApp extends StatelessWidget {
  const RampCheckApp({
    super.key, 
    required this.jobRepo, 
    required this.attachmentRepo,
    required this.syncService,
  });
  
  final JobRepository jobRepo;
  final AttachmentRepository attachmentRepo;
  final SyncService syncService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RampCheck',
      theme: ThemeData(useMaterial3: true),
      home: JobListPage(
        jobRepo: jobRepo, 
        attachmentRepo: attachmentRepo,
        syncService: syncService
      ),
    );
  }
}