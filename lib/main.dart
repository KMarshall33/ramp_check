import 'package:flutter/material.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/ui/job_list_page.dart';
import 'package:ramp_check/data/repositories/attachment_repository.dart';
import 'package:ramp_check/core/file_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final jobRepo = JobRepository(db);
  final attachmentRepo = AttachmentRepository(
    db, 
    FileStorageService()
  );

  runApp(RampCheckApp(
    jobRepo: jobRepo, 
    attachmentRepo: attachmentRepo
  ));
}

class RampCheckApp extends StatelessWidget {
  const RampCheckApp({
    super.key, 
    required this.jobRepo, 
    required this.attachmentRepo
  });
  
  final JobRepository jobRepo;
  final AttachmentRepository attachmentRepo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RampCheck',
      theme: ThemeData(useMaterial3: true),
      home: JobListPage(
        jobRepo: jobRepo, 
        attachmentRepo: attachmentRepo
      ),
    );
  }
}