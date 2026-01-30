import 'package:drift/native.dart';
import 'package:ramp_check/data/local/app_database.dart';

AppDatabase createTestDb() {
  // Uses in-memory SQLite, no path_provider, no filesystem.
  return AppDatabase.forTesting(NativeDatabase.memory());
}
