import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turo/firebase_options.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:mockito/mockito.dart';

// Manual mock for FirebaseCoreHostApi
class MockFirebaseCoreHostApi extends Mock implements FirebaseCoreHostApi {
  @override
  Future<List<FirebaseApp>> initializeCore() async {
    return [MockFirebaseApp()];
  }

  @override
  Future<FirebaseApp> initializeApp({String? appName, FirebaseOptions? options}) async {
    return MockFirebaseApp();
  }
}

// Mock for FirebaseApp
class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('Fetch users from Firestore', () async {
    // Get an instance of Firestore
    final firestore = FirebaseFirestore.instance;

    // Get the users collection
    final usersCollection = firestore.collection('users');

    // Get the documents in the collection
    final querySnapshot = await usersCollection.get();

    // Print the data of each document
    for (var doc in querySnapshot.docs) {
      print('User ID: ${doc.id}');
      print('User data: ${doc.data()}');
    }
  });
}

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockCore = MockFirebaseCoreHostApi();
  Firebase.delegatePackingProperty = "version=1.0.0";
  FirebaseCoreHostApi.setup(mockCore);
}