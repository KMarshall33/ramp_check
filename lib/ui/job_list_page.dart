import 'package:flutter/material.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:ramp_check/ui/add_job_page.dart';
import 'package:ramp_check/data/repositories/attachment_repository.dart';
import 'package:ramp_check/ui/attachments_page.dart';
import 'package:ramp_check/sync/sync_service.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('RampCheck Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final result = await syncService.runSync();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sync complete: jobs=${result.syncedJobs} attachments=${result.syncedAttachments} '
                    '(${result.durationMs}ms)',
                  ),
                ),
              );
            },
          ),
        ],
      ),

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
                    final sw = Stopwatch()..start();

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentsPage(
                          jobId: j.id,
                          repo: attachmentRepo,
                          onFirstFrame: () {
                            sw.stop();
                            // ignore: avoid_print
                            print('UI timing: open_attachments_first_frame_ms=${sw.elapsedMilliseconds}');
                            },
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
