import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'your-api-key',
          appId: 'your-app-id',
          messagingSenderId: 'your-messaging-sender-id',
          projectId: 'turo-31805',
        ),
      );
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
}