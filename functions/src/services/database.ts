import admin from "./firebase";
import { UserProfile } from "../models/user_profile";

/**
 * Service class for managing database operations with Firestore.
 *
 * Provides methods to create, read, and update user profiles.
 */
class DatabaseService {
  private db: admin.firestore.Firestore;

  // Collection name constants
  private static readonly USER_PROFILES_COLLECTION = 'user_profiles';
  private static readonly VERIFICATION_FILES_COLLECTION = 'verification_files';

  constructor() {
    // Initialize Firestore with the 'turo' database
    this.db = admin.firestore();
    try {
        this.db.settings({ databaseId: 'turo' });
    } catch (e) {
        console.log(e)
    }
  }

  /**
   * Retrieves a user profile by user ID.
   *
   * @param {string} userId - The user's unique identifier.
   * @returns {Promise<admin.firestore.DocumentData | null>} The user profile data or null if not found.
   */
  async getUserProfile(userId: string): Promise<admin.firestore.DocumentData | null> {
    const doc = await this.db.collection(DatabaseService.USER_PROFILES_COLLECTION).doc(userId).get();
    return doc.exists ? doc.data()! : null;
  }

  /**
   * Updates an existing user profile.
   *
   * @param {string} userId - The user's unique identifier.
   * @param {Partial<UserProfile>} profile - The profile data to update.
   */
  async updateUserProfile(userId: string, profile: Partial<UserProfile>): Promise<void> {
    const userProfileRef = this.db.collection(DatabaseService.USER_PROFILES_COLLECTION).doc(userId);
    const userProfileData = {
      ...profile,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };
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
  async addVerificationFile(userId: string, fileUrl: string, fileType: string, fileName: string): Promise<void> {
    const verificationFileRef = this.db
        .collection(DatabaseService.USER_PROFILES_COLLECTION)
        .doc(userId)
        .collection(DatabaseService.VERIFICATION_FILES_COLLECTION)
        .doc(); // Creates a new document with a random ID

    const verificationFileData = {
        file_name: fileName,
        file_url: fileUrl,
        file_type: fileType,
        uploaded_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    await verificationFileRef.set(verificationFileData);
  }
}

export const databaseService = new DatabaseService();
