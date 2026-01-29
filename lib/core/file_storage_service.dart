import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoredFileResult {
  StoredFileResult({
    required this.storedPath,
    required this.fileSizeBytes,
    required this.sha256Hex,
    required this.mimeType,
    required this.originalName,
  });

  final String storedPath;
  final int fileSizeBytes;
  final String sha256Hex;
  final String mimeType;
  final String originalName;
}

class FileStorageService {
  Future<StoredFileResult> storeJobAttachment({
    required String jobId,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Source file does not exist: $sourcePath');
    }

    final originalName = p.basename(sourcePath);
    final appDir = await getApplicationDocumentsDirectory();

    final attachmentsDir = Directory(p.join(appDir.path, 'attachments', jobId));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    // Use a timestamp prefix to avoid collisions without needing extra deps here
    final safeName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final storedPath = p.join(attachmentsDir.path, safeName);

    final storedFile = await sourceFile.copy(storedPath);
    final bytes = await storedFile.readAsBytes();

    final hash = sha256.convert(bytes).toString();
    final size = bytes.length;

    // Minimal mime type inference (enough for metadata)
    final ext = p.extension(originalName).toLowerCase();
    final mimeType = _guessMimeType(ext);

    return StoredFileResult(
      storedPath: storedPath,
      fileSizeBytes: size,
      sha256Hex: hash,
      mimeType: mimeType,
      originalName: originalName,
    );
  }

  String _guessMimeType(String ext) {
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
