"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const firebase_functions_test_1 = __importDefault(require("firebase-functions-test"));
const assert = __importStar(require("assert"));
const index_1 = require("./index");
// Initialize the test environment
const test = (0, firebase_functions_test_1.default)();
const testEnv = test;
describe('User Profile Cloud Functions', () => {
    let wrapped;
    before(() => {
        wrapped = testEnv.wrap(index_1.saveUserProfile);
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
        assert.deepStrictEqual(userDetailDoc.data(), Object.assign(Object.assign({}, mockUserDetail), { 
            // The birthdate and createdAt fields are converted to Timestamps by the function
            birthdate: admin.firestore.Timestamp.fromDate(new Date(mockUserDetail.birthdate)), createdAt: admin.firestore.Timestamp.fromDate(new Date(mockUserDetail.createdAt)) }));
    });
});
//# sourceMappingURL=test.js.map