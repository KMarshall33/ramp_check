import 'package:flutter/material.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/ui/add_job_page.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({super.key, required this.repo});

  final JobRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RampCheck Jobs')),
      body: StreamBuilder(
        stream: repo.watchJobs(),
        builder: (context, snapshot) {
          final jobs = snapshot.data ?? const [];
          return ListView.separated(
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final j = jobs[index];
              return ListTile(
                title: Text(j.aircraftRef),
                subtitle: Text('${j.location} • ${j.status} • ${j.syncStatus}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddJobPage(repo: repo)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
