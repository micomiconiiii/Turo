import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turo/services/database_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late DatabaseService databaseService;
  late MockFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;

  setUp(() {
    mockFirestore = MockFirestore();
    databaseService = DatabaseService();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();

    // You might need to adjust this setup depending on your DatabaseService implementation
    when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
  });

  group('DatabaseService Tests', () {
    test('updateUserDetails should include email when provided', () async {
      final uid = 'test_uid';
      final fullName = 'Test User';
      final birthdate = DateTime.now();
      final address = '123 Test St';
      final email = 'test@example.com';

      // Stub the set method to capture the data
      ArgumentCaptor<Map<String, dynamic>>? capturedData;

      when(mockDocumentReference.set(any, any)).thenAnswer((realInvocation) async {
        capturedData = ArgumentCaptor<Map<String, dynamic>>();
        return Future.value();
      });

      // Spying on the behavior of the real database service
      final dbServiceSpy = DatabaseService();

      // Act
      await dbServiceSpy.updateUserDetails(
        uid: uid,
        fullName: fullName,
        birthdate: birthdate,
        address: address,
        email: email,
      );

      // Assert
      verify(mockDocumentReference.set(captureAny, any)).called(1);
      
      final data = capturedData?.value;

      expect(data, isNotNull);
      expect(data!['email'], email);
    });
  });
}
