import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// StorageService centralizes all file upload interactions with Firebase Storage.
///
/// Typical usage:
/// final storage = StorageService();
/// final url = await storage.uploadFile('users/<uid>/profile.jpg', file);
class StorageService {
  // Firebase Storage singleton instance (private to enforce single access point)
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to the given [destinationPath] in Firebase Storage and
  /// return the public download URL as a String.
  ///
  /// Example destinationPath values:
  /// - 'users/<uid>/profile.jpg'
  /// - 'users/<uid>/certifications/cert123.pdf'
  Future<String> uploadFile(
    String destinationPath,
    File file, {
    SettableMetadata? metadata,
  }) async {
    try {
      final Reference ref = _storage.ref(destinationPath);

      // Determine content type from file extension if not provided
      SettableMetadata? uploadMetadata = metadata;
      if (uploadMetadata == null) {
        final extension = destinationPath.split('.').last.toLowerCase();
        String? contentType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          case 'gif':
            contentType = 'image/gif';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          case 'pdf':
            contentType = 'application/pdf';
            break;
        }
        if (contentType != null) {
          uploadMetadata = SettableMetadata(contentType: contentType);
        }
      }

      // Start the upload and wait for completion
      await ref.putFile(file, uploadMetadata);

      // Retrieve a download URL for the uploaded file
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Print error for debugging and rethrow a descriptive exception
      // (Callers can catch and display a friendly message)
      // ignore: avoid_print
      print('Storage upload failed for "$destinationPath": $e');
      throw Exception('Failed to upload file to Storage');
    }
  }

  /// Upload raw bytes (useful for Web or when you already have in-memory data)
  /// and return the download URL.
  Future<String> uploadBytes(
    String destinationPath,
    Uint8List data, {
    SettableMetadata? metadata,
  }) async {
    try {
      final Reference ref = _storage.ref(destinationPath);
      await ref.putData(data, metadata);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Storage upload (bytes) failed for "$destinationPath": $e');
      throw Exception('Failed to upload bytes to Storage');
    }
  }
}
