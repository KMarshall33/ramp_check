import 'package:flutter/material.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key, required this.repo});

  final JobRepository repo;

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _aircraftCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _aircraftCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final aircraftRef = _aircraftCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (aircraftRef.isEmpty || location.isEmpty) return;

    await widget.repo.createJob(
      aircraftRef: aircraftRef,
      location: location,
    );

    // Minimal debugging evidence
    // ignore: avoid_print
    print('Job created: aircraftRef=$aircraftRef location=$location');

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _aircraftCtrl,
              decoration: const InputDecoration(labelText: 'Aircraft reference'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
