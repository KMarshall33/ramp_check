import 'package:flutter/material.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/ui/job_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final repo = JobRepository(db);

  runApp(RampCheckApp(repo: repo));
}

class RampCheckApp extends StatelessWidget {
  const RampCheckApp({super.key, required this.repo});

  final JobRepository repo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RampCheck',
      theme: ThemeData(useMaterial3: true),
      home: JobListPage(repo: repo),
    );
  }
}