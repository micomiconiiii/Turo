import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Cloud Function: onAuthUserDeleted
 * 
 * Cascading delete handler triggered when a Firebase Auth user is deleted.
 * Cleans up all associated data across Firestore collections and Storage.
 * 
 * Database Schema (3 Layers):
 * - Layer 1 (Public): users/{uid}
 * - Layer 2 (Private): user_details/{uid}
 * - Layer 3 (Admin): mentor_verifications/{uid}
 * 
 * Storage Structure:
 * - users/{uid}/... (profile photos, ID documents, etc.)
 */
export const onAuthUserDeleted = functions.auth.user().onDelete(async (user: admin.auth.UserRecord) => {
  const uid = user.uid;
  console.log(`[Cleanup] Starting cascading delete for user: ${uid}`);

  try {
    // 1. Firestore Cleanup - Batch delete all user documents
    const db = admin.firestore();
    const batch = db.batch();

    // Target all three layers of the schema
    const usersRef = db.collection("users").doc(uid);
    const userDetailsRef = db.collection("user_details").doc(uid);
    const mentorVerificationsRef = db.collection("mentor_verifications").doc(uid);

    console.log(`[Cleanup] Targeting Firestore documents:`);
    console.log(`  - users/${uid}`);
    console.log(`  - user_details/${uid}`);
    console.log(`  - mentor_verifications/${uid}`);

    // Add deletions to batch
    batch.delete(usersRef);
    batch.delete(userDetailsRef);
    batch.delete(mentorVerificationsRef);

    // Execute atomic batch delete
    await batch.commit();
    console.log(`[Cleanup] Successfully deleted Firestore documents for uid: ${uid}`);

    // 2. Storage Cleanup - Delete all files under users/{uid}/
    const bucket = admin.storage().bucket();
    const storagePrefix = `users/${uid}/`;

    console.log(`[Cleanup] Deleting storage files with prefix: ${storagePrefix}`);

    try {
      // List all files with the user's prefix
      const [files] = await bucket.getFiles({ prefix: storagePrefix });

      if (files.length === 0) {
        console.log(`[Cleanup] No storage files found for uid: ${uid}`);
      } else {
        console.log(`[Cleanup] Found ${files.length} file(s) to delete`);

        // Delete all files in parallel
        await Promise.all(files.map((file) => {
          console.log(`[Cleanup] Deleting file: ${file.name}`);
          return file.delete();
        }));

        console.log(`[Cleanup] Successfully deleted all storage files for uid: ${uid}`);
      }
    } catch (storageError) {
      // Log storage errors but don't fail the entire cleanup
      console.error(`[Cleanup] Error deleting storage files for uid: ${uid}`, storageError);
      console.log(`[Cleanup] Continuing despite storage error...`);
    }

    console.log(`[Cleanup] Cascading delete completed successfully for uid: ${uid}`);
  } catch (error) {
    console.error(`[Cleanup] Failed to cleanup user data for uid: ${uid}`, error);
    throw new functions.https.HttpsError(
      "internal",
      `Failed to cleanup user account: ${error}`
    );
  }
});
