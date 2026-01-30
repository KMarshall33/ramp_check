import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyStore {
  ApiKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyName = 'api_key';

  Future<void> setApiKey(String apiKey) => _storage.write(key: _keyName, value: apiKey);

  Future<String?> getApiKey() => _storage.read(key: _keyName);
}
