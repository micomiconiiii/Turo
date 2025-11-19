import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * User Statistics Aggregator
 *
 * Maintains real-time dashboard statistics by tracking user registrations.
 * Triggers on new user_details documents and updates:
 * 1. Global counters in sys_stats/dashboard_counters
 * 2. Daily breakdown in daily_stats/{YYYY-MM-DD}
 *
 * This ensures the admin dashboard displays accurate metrics without
 * expensive collection queries.
 */
export const onUserVerified = functions.firestore
  .document("user_details/{uid}")
  .onCreate(async (
    snapshot: functions.firestore.QueryDocumentSnapshot,
    context: functions.EventContext
  ) => {
    const db = admin.firestore();
    const batch = db.batch();

    // Extract user role from the new document
    const data = snapshot.data();
    const role: string = data?.role || "mentee"; // Default to mentee if missing

    // Determine current date key for daily stats (UTC)
    const now = new Date();
    const dateKey = now.toISOString().split("T")[0]; // YYYY-MM-DD

    try {
      // ========== Operation A: Update Global Counters ==========
      const globalStatsRef = db.doc("sys_stats/dashboard_counters");

      // Build dynamic field updates based on role
      const globalUpdates: { [key: string]: admin.firestore.FieldValue } = {
        total_users: admin.firestore.FieldValue.increment(1),
        new_users_24h: admin.firestore.FieldValue.increment(1),
        last_updated: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Increment role-specific counter (total_mentors or total_mentees)
      if (role === "mentor" || role === "mentee") {
        globalUpdates[`total_${role}s`] = admin.firestore.FieldValue.increment(1);
      }

      batch.set(globalStatsRef, globalUpdates, { merge: true });

      // ========== Operation B: Update Daily Chart Data ==========
      const dailyStatsRef = db.doc(`daily_stats/${dateKey}`);

      const dailyUpdates: { [key: string]: admin.firestore.FieldValue | string } = {
        total_registrations: admin.firestore.FieldValue.increment(1),
        date: dateKey, // Store for easy querying
      };

      // Increment role-specific daily counter (new_mentors or new_mentees)
      if (role === "mentor" || role === "mentee") {
        dailyUpdates[`new_${role}s`] = admin.firestore.FieldValue.increment(1);
      }

      batch.set(dailyStatsRef, dailyUpdates, { merge: true });

      // ========== Commit Atomic Batch ==========
      await batch.commit();

      functions.logger.info(
        `Stats updated for user ${context.params.uid} (${role}): ` +
        `global counters and daily_stats/${dateKey}`
      );
    } catch (error) {
      functions.logger.error(
        `Failed to update stats for user ${context.params.uid}:`,
        error
      );
      // Don't throw - allow user creation to succeed even if stats fail
    }
  });

/**
 * Nightly Stats Reset
 *
 * Scheduled Cloud Function that runs daily at 00:00 Manila Time (Asia/Manila)
 * to reset the 24-hour user counter for the admin dashboard.
 *
 * Resets: sys_stats/dashboard_counters.new_users_24h to 0
 */
export const resetDailyStats = functions.pubsub
  .schedule("0 0 * * *") // Every day at midnight
  .timeZone("Asia/Manila") // Manila timezone
  .onRun(async (context) => {
    const db = admin.firestore();
    const globalStatsRef = db.doc("sys_stats/dashboard_counters");

    try {
      await globalStatsRef.set(
        {
          new_users_24h: 0,
          last_updated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      functions.logger.info("Nightly stats reset complete.");
    } catch (error) {
      functions.logger.error("Failed to reset nightly stats:", error);
      throw error; // Rethrow to mark the scheduled job as failed
    }
  });
