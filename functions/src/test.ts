import firebaseFunctionsTest from 'firebase-functions-test';
import * as assert from 'assert';
import { saveUserProfile } from './index';

// Initialize the test environment
const test = firebaseFunctionsTest();
const testEnv = test;

describe('User Profile Cloud Functions', () => {
  let wrapped: any;

  before(() => {
    wrapped = testEnv.wrap(saveUserProfile);
  });

  after(() => {
    // Clean up the test environment
    testEnv.cleanup();
  });

  it('should save user profile data to Firestore', async () => {
    // Mock user data
    const mockUser = {
      userId: 'test-uid',
      displayName: 'Test User',
      bio: 'This is a test bio.',
      roles: ['mentor'],
    };

    const mockUserDetail = {
      userId: 'test-uid',
      email: 'test@example.com',
      fullName: 'Test User',
      birthdate: new Date('1990-01-01').toISOString(),
      address: '123 Test St',
      createdAt: new Date().toISOString(),
    };

    // Mock request object
    const mockRequest = {
      auth: {
        uid: 'test-uid',
        token: {
          email: 'test@example.com',
        },
      },
      data: {
        user: mockUser,
        userDetail: mockUserDetail,
      },
    };

    // Call the wrapped function
    await wrapped(mockRequest);

    // Verify the data was saved to Firestore
    const admin = require('firebase-admin');
    const db = admin.firestore();

    const userDoc = await db.collection('users').doc('test-uid').get();
    const userDetailDoc = await db.collection('user_details').doc('test-uid').get();

    assert.ok(userDoc.exists, 'User document should exist');
    assert.deepStrictEqual(userDoc.data(), mockUser);

    assert.ok(userDetailDoc.exists, 'User detail document should exist');
    assert.deepStrictEqual(userDetailDoc.data(), {
        ...mockUserDetail,
        email: mockRequest.auth.token.email,
        // The birthdate and createdAt fields are converted to Timestamps by the function
        birthdate: admin.firestore.Timestamp.fromDate(new Date(mockUserDetail.birthdate)),
        createdAt: admin.firestore.Timestamp.fromDate(new Date(mockUserDetail.createdAt)),
    });
  });
});
