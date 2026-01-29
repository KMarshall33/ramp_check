import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ramp_check/data/repositories/attachment_repository.dart';

class AttachmentsPage extends StatelessWidget {
  const AttachmentsPage({
    super.key,
    required this.jobId,
    required this.repo,
  });

  final String jobId;
  final AttachmentRepository repo;

  Future<void> _pickAndAddAttachment(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;

    await repo.addForJob(jobId: jobId, sourcePath: path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attachments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndAddAttachment(context),
        child: const Icon(Icons.attach_file),
      ),
      body: StreamBuilder(
        stream: repo.watchForJob(jobId),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No attachments yet'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = items[index];
              return ListTile(
                title: Text(a.filePath.split(RegExp(r'[\\/]+')).last),
                subtitle: Text('${a.mimeType} • ${a.syncStatus} • ${a.fileSizeBytes} bytes'),
              );
            },
          );
        },
      ),
    );
  }
}
