import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const app = admin.app();

// Create separate Firestore instances for different databases
// Initialize Firestore with the named database 'turo' (lowercase)
const firestore = admin.firestore(app);

// Apply settings before any operations
firestore.settings({
  databaseId: "turo"
});

export const db = firestore;
export const turoDb = firestore;

export const auth = admin.auth();

export default admin;