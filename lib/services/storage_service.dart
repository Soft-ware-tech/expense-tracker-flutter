import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Handles uploading and deleting expense receipt photos in Firebase
/// Storage. Every file is stored under receipts/{uid}/... so a user can
/// only ever be pointed at (and, via storage.rules, only ever read/write)
/// their own receipts.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Uploads [file] and returns its public download URL.
  Future<String> uploadReceipt(File file) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to upload a receipt.');
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('receipts/$uid/$fileName');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  /// Best-effort delete; failures are swallowed since a missing/old file
  /// should never block the user from editing or deleting an expense.
  Future<void> deleteReceipt(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (_) {
      // Ignore - file may already be gone, or URL may be malformed.
    }
  }
}
