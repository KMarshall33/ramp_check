class SyncConfig {
  // Windows desktop can reach local Flask directly
  static const windowsBaseUrl = 'http://127.0.0.1:5000';

  // Android emulator uses 10.0.2.2 to reach host localhost
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:5000';
}
