import 'package:flutter/material.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/ui/add_job_page.dart';
import 'package:ramp_check/data/repositories/attachment_repository.dart';
import 'package:ramp_check/ui/attachments_page.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({
    super.key, 
    required this.jobRepo,
    required this.attachmentRepo,
  });

  final JobRepository jobRepo;
  final AttachmentRepository attachmentRepo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RampCheck Jobs')),
      body: StreamBuilder(
        stream: jobRepo.watchJobs(),
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
                trailing: IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentsPage(
                          jobId: j.id,
                          repo: attachmentRepo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddJobPage(repo: jobRepo)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
