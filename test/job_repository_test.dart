import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_check/data/local/app_database.dart';
import 'package:ramp_check/data/repositories/job_repository.dart';
import 'package:drift/native.dart';

void main() {
  test('JobRepository creates and returns jobs', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = JobRepository(db);

    await repo.createJob(aircraftRef: 'G-TEST', location: 'Bay 1');

    final jobs = await (db.select(db.jobs)).get();
    expect(jobs.length, 1);
    expect(jobs.first.aircraftRef, 'G-TEST');
    expect(jobs.first.syncStatus, 'pending');

    await db.close();
  });
}
