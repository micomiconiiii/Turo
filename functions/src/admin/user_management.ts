import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Cloud Function: toggleUserBan
 * * Callable function for Admins to Ban/Unban a user.
 * This secures the app by disabling the user's access at the Auth level.
 * * Actions:
 * 1. Updates Firebase Auth (disabled: true/false).
 * 2. Updates Firestore 'user_details' (is_active: false/true).
 * 3. Logs the action in 'activities' collection.
 */
export const toggleUserBan = functions.https.onCall(
  async (data: any, context: functions.https.CallableContext) => {
    // 1. SECURITY: Ensure caller is Authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const callerUid = context.auth.uid;
    const db = admin.firestore();

    // --- CRITICAL FIX: Connect to 'turo' database ---
    try {
      db.settings({ databaseId: "turo" });
    } catch (e) {
      // Ignore error if settings were already applied
    }
    // ------------------------------------------------

    // 2. SECURITY: Ensure caller is an Admin
    const callerDoc = await db.collection("users").doc(callerUid).get();
    const roles = callerDoc.data()?.roles || [];

    if (!Array.isArray(roles) || !roles.includes("admin")) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can perform this action."
      );
    }

    // 3. VALIDATION: Check inputs
    const targetUid: string = data.uid;
    const shouldBan: boolean = data.shouldBan;

    if (!targetUid || typeof shouldBan !== "boolean") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with 'uid' and 'shouldBan' arguments."
      );
    }

    try {
      console.log(`[Admin Action] ${shouldBan ? "Banning" : "Unbanning"} user: ${targetUid}`);

      // 1. Auth: Hard Ban
      await admin.auth().updateUser(targetUid, {
        disabled: shouldBan,
      });

      // 2. Private DB: Soft Ban
      await db.collection("user_details").doc(targetUid).update({
        is_active: !shouldBan,
      });

      // 3. Public DB: UI Sync (NEW!)
      // This forces the Admin Table stream to update immediately
      await db.collection("users").doc(targetUid).set({
        is_active: !shouldBan 
      }, { merge: true });

      // 4. Audit Log
      await db.collection("activities").add({
        event_type: shouldBan ? "user_banned" : "user_unbanned",
        description: `User ${targetUid} was ${shouldBan ? "suspended" : "activated"} by admin.`,
        related_user_id: targetUid,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: `User ${shouldBan ? "banned" : "activated"} successfully.`,
      };
    } catch (error) {
      console.error("Ban Error:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to update user status.",
        error
      );
    }
  }
);

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
 */
export const onAuthUserDeleted = functions.auth.user().onDelete(async (user: admin.auth.UserRecord) => {
  const uid = user.uid;
  console.log(`[Cleanup] Starting cascading delete for user: ${uid}`);

  try {
    const db = admin.firestore();
    
    // --- CRITICAL FIX: Connect to 'turo' database ---
    try {
      db.settings({ databaseId: "turo" });
    } catch (e) {
      // Ignore error if settings were already applied
    }
    // ------------------------------------------------

    const batch = db.batch();

    // 1. Firestore Cleanup - Target all three layers
    const usersRef = db.collection("users").doc(uid);
    const userDetailsRef = db.collection("user_details").doc(uid);
    const mentorVerificationsRef = db.collection("mentor_verifications").doc(uid);

    console.log(`[Cleanup] Deleting Firestore docs for ${uid}`);
    batch.delete(usersRef);
    batch.delete(userDetailsRef);
    batch.delete(mentorVerificationsRef);

    // Execute atomic batch delete
    await batch.commit();
    console.log(`[Cleanup] Firestore documents deleted.`);

    // 2. Storage Cleanup - Delete all files under users/{uid}/
    const bucket = admin.storage().bucket();
    const storagePrefix = `users/${uid}/`;

    console.log(`[Cleanup] Deleting storage files with prefix: ${storagePrefix}`);
    
    try {
      // List all files with the user's prefix
      const [files] = await bucket.getFiles({ prefix: storagePrefix });

      if (files.length === 0) {
        console.log(`[Cleanup] No storage files found.`);
      } else {
        // Delete all files in parallel
        await Promise.all(files.map((file) => file.delete()));
        console.log(`[Cleanup] Deleted ${files.length} storage files.`);
      }
    } catch (storageError) {
      // Log storage errors but don't fail the entire function
      console.error(`[Cleanup] Storage error (non-fatal):`, storageError);
    }

    console.log(`[Cleanup] Complete for uid: ${uid}`);
  } catch (error) {
    console.error(`[Cleanup] Failed to cleanup user data for uid: ${uid}`, error);
    // We don't throw here to avoid infinite retry loops in some configurations,
    // but logging the error is critical.
  }
});