"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.databaseService = void 0;
const firebase_1 = __importDefault(require("./firebase"));
/**
 * Service class for managing database operations with Firestore.
 *
 * Provides methods to create, read, and update user profiles.
 */
class DatabaseService {
    constructor() {
        // Initialize Firestore with the 'turo' database
        this.db = firebase_1.default.firestore();
        try {
            this.db.settings({ databaseId: 'turo' });
        }
        catch (e) {
            console.log(e);
        }
    }
    /**
     * Retrieves a user profile by user ID.
     *
     * @param {string} userId - The user's unique identifier.
     * @returns {Promise<admin.firestore.DocumentData | null>} The user profile data or null if not found.
     */
    async getUserProfile(userId) {
        const doc = await this.db.collection(DatabaseService.USER_PROFILES_COLLECTION).doc(userId).get();
        return doc.exists ? doc.data() : null;
    }
    /**
     * Updates an existing user profile.
     *
     * @param {string} userId - The user's unique identifier.
     * @param {Partial<UserProfile>} profile - The profile data to update.
     */
    async updateUserProfile(userId, profile) {
        const userProfileRef = this.db.collection(DatabaseService.USER_PROFILES_COLLECTION).doc(userId);
        const userProfileData = Object.assign(Object.assign({}, profile), { updated_at: firebase_1.default.firestore.FieldValue.serverTimestamp() });
        await userProfileRef.set(userProfileData, { merge: true });
    }
    /**
     * Adds a verification file record to a user's profile.
     *
     * @param {string} userId - The user's unique identifier.
     * @param {string} fileUrl - The URL of the uploaded file in Firebase Storage.
     * @param {string} fileType - The type of the file (e.g., 'selfie', 'credential', 'id_front').
     * @param {string} fileName - The name of the file.
     */
    async addVerificationFile(userId, fileUrl, fileType, fileName) {
        const verificationFileRef = this.db
            .collection(DatabaseService.USER_PROFILES_COLLECTION)
            .doc(userId)
            .collection(DatabaseService.VERIFICATION_FILES_COLLECTION)
            .doc(); // Creates a new document with a random ID
        const verificationFileData = {
            file_name: fileName,
            file_url: fileUrl,
            file_type: fileType,
            uploaded_at: firebase_1.default.firestore.FieldValue.serverTimestamp(),
        };
        await verificationFileRef.set(verificationFileData);
    }
}
// Collection name constants
DatabaseService.USER_PROFILES_COLLECTION = 'user_profiles';
DatabaseService.VERIFICATION_FILES_COLLECTION = 'verification_files';
exports.databaseService = new DatabaseService();
//# sourceMappingURL=database.js.map