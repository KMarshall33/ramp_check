# RampCheck

RampCheck is a cross-platform Flutter app built for the Cross-Platform Programming module. It demonstrates an offline-first approach using Drift (SQLite) for local persistence, with manual and automatic synchronisation to a local Flask API when connectivity is available.

## Key features

- Offline-first local persistence with Drift (SQLite)
- CRUD for jobs and attachment metadata
- Manual sync from the UI and auto sync when connectivity is restored
- API key stored using secure storage
- Unit tests using an in-memory Drift database and mocked HTTP client

## Run the app

From the project root:

### Windows
```
flutter run -d windows
```
### Android emulator
```
flutter run -d emulator
```

Note: when using a local Flask API, Windows uses `http://127.0.0.1` and the Android emulator uses `http://10.0.2.2`.

## Run tests

From the project root:
```
flutter test
```
