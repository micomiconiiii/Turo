import 'package:flutter/foundation.dart' show kIsWeb;

abstract class StorageService {
  Future<String?> uploadIdDocument({
    required dynamic file, // File for mobile, Uint8List for web
    required String idType,
  });
  
  static StorageService getInstance() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return MobileStorageService();
    }
  }
}

// For Web - Use Supabase Storage
class WebStorageService implements StorageService {
  @override
  Future<String?> uploadIdDocument({
    required dynamic file,
    required String idType,
  }) async {
    // TODO: Implement Supabase Storage upload for web
    print('Web upload not yet implemented - using Supabase');
    await Future.delayed(Duration(seconds: 1)); // Simulate upload
    return 'https://example.com/uploaded-file.jpg';
  }
}

// For Mobile - Use Firebase Storage
class MobileStorageService implements StorageService {
  @override
  Future<String?> uploadIdDocument({
    required dynamic file,
    required String idType,
  }) async {
    // Your existing Firebase Storage code
    return null;
  }
}