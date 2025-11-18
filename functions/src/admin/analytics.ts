import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {defineString} from "firebase-functions/params";

// Admin-only key to run maintenance tasks like backfills
const backfillKey = defineString("BACKFILL_KEY");

// Get Firestore instance with turo database
function getTuroDb() {
  const db = admin.firestore();
  // Set databaseId if not already set
  try {
    // @ts-ignore
    if (!db._settings || !db._settings.databaseId) {
      // @ts-ignore
      db.settings({ databaseId: "turo" });
    }
  } catch {
    // Already configured, continue
  }
  return db;
}

/**
 * Backfills missing created_at / updated_at timestamps in the 'users' collection.
 *
 * Security:
 * - Requires a shared key via query `?key=...` or header `x-admin-key` that matches BACKFILL_KEY param.
 * - Recommended to run once and then rotate/remove the key.
 *
 * Behavior:
 * - For each user document:
 *   - If created_at is missing, sets it to the document's createTime.
 *   - If updated_at is missing, sets it to the document's updateTime (or serverTimestamp if missing).
 * - Supports dry-run mode with `?dryRun=true` to preview counts without writing.
 */
export const backfillUserTimestamps = functions.https.onRequest(async (req, res) => {
  try {
    // Set CORS headers to allow browser requests
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type, x-admin-key');

    // Handle preflight
    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    const keyFromReq = (req.query.key as string) || (req.headers["x-admin-key"] as string);
    const configuredKey = backfillKey.value() || process.env.BACKFILL_KEY || "";
    // Debug (safe) logging: do NOT log actual key values, only lengths and presence
    console.log("[backfill] Incoming key present:", Boolean(keyFromReq), "len:", keyFromReq ? keyFromReq.length : 0);
    console.log("[backfill] Configured key present:", Boolean(configuredKey), "len:", configuredKey.length);
    if (!configuredKey) {
      res.status(500).json({ error: "BACKFILL_KEY not configured" });
      return;
    }
    if (!keyFromReq || keyFromReq !== configuredKey) {
      res.status(403).json({ error: "Forbidden" });
      return;
    }

    const dryRun = String(req.query.dryRun || "false").toLowerCase() === "true";

    // Get Firestore instance with turo database
    const turoDb = getTuroDb();

    const usersSnap = await turoDb.collection("users").get();    let scanned = 0;
    let toUpdate = 0;
    let createdAtSet = 0;
    let updatedAtSet = 0;

    const BATCH_LIMIT = 400;
    let batch = turoDb.batch();

    for (const doc of usersSnap.docs) {
      scanned++;
      const data = doc.data() || {} as Record<string, unknown>;

      const hasCreated = Object.prototype.hasOwnProperty.call(data, "created_at");
      const hasUpdated = Object.prototype.hasOwnProperty.call(data, "updated_at");

      const update: Record<string, admin.firestore.FieldValue | admin.firestore.Timestamp> = {};

      if (!hasCreated) {
        // Prefer server-side document createTime if available
        const createTs = (doc.createTime as admin.firestore.Timestamp) || admin.firestore.Timestamp.now();
        update["created_at"] = createTs;
        createdAtSet++;
      }

      if (!hasUpdated) {
        const updateTs = (doc.updateTime as admin.firestore.Timestamp) || admin.firestore.Timestamp.now();
        update["updated_at"] = updateTs;
        updatedAtSet++;
      }

      if (Object.keys(update).length > 0) {
        toUpdate++;
        if (!dryRun) {
          batch.update(doc.ref, update);
          if (toUpdate % BATCH_LIMIT === 0) {
            await batch.commit();
            batch = turoDb.batch();
          }
        }
      }
    }

    if (!dryRun && toUpdate % BATCH_LIMIT !== 0) {
      await batch.commit();
    }

    res.json({
      dryRun,
      scanned,
      toUpdate,
      createdAtSet,
      updatedAtSet,
      message: dryRun ? "Dry run: no writes performed" : "Backfill completed",
    });
  } catch (err) {
    console.error("Backfill error:", err);
    res.status(500).json({ error: String(err) });
  }
});
