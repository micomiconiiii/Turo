import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
import {defineString} from "firebase-functions/params";

// Define email and password as environment variables (lazy-loaded)
const emailProvider = defineString("EMAIL", {default: ""});
const passwordProvider = defineString("PASSWORD", {default: ""});

// Initialize Firebase Admin SDK and Firestore
admin.initializeApp();
const db = admin.firestore();

// Define interfaces for callable function data
interface RequestEmailOTPData {
  email: string;
}

interface VerifyEmailOTPData {
  email: string;
  otp: string;
}

// Configure Nodemailer - get values lazily to avoid deployment timeouts
function getTransporter() {
  return nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      user: emailProvider.value(),
      pass: passwordProvider.value(),
    },
  });
}

/**
 * A callable Cloud Function to request an OTP for a given email address.
 * It generates a 6-digit OTP, saves it to Firestore with a 10-minute expiry,
 * and sends it to the user's email.
 */
export const requestEmailOTP = functions.https.onCall(async (request) => {
  const data = request.data as RequestEmailOTPData;
  const email = data['email'];

  console.log("📩 OTP request received for:", email);

  if (!email || !/\S+@\S+\.\S+/.test(email)) {
    console.error("❌ Invalid email format");
    throw new functions.https.HttpsError("invalid-argument", "A valid email address is required.");
  }

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiration = new Date(Date.now() + 10 * 60 * 1000);
  const otpDoc = { email, otp, expires: expiration };

  console.log("🗄️ Attempting to save OTP to Firestore:", otpDoc);

  await db.collection("otps").doc(email).set(otpDoc);

  console.log("✅ OTP saved to Firestore successfully");

  try {
    const mailOptions = {
      from: emailProvider.value(),
      to: email,
      subject: "Your OTP for TURO Email Verification",
      html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
          }
          .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .header {
            text-align: center;
            padding-bottom: 20px;
          }
          .content {
            /* No alignment by default */
          }
          .otp-container {
            text-align: center;
          }
          .otp-code {
            font-size: 36px;
            font-weight: bold;
            color: #333333;
            letter-spacing: 2px;
            margin: 20px 0;
            padding: 15px;
            border: 1px dashed #dddddd;
            display: inline-block;
          }
          .footer {
            text-align: center;
            font-size: 12px;
            color: #777777;
            padding-top: 20px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>TURO Email Verification</h2>
          </div>
          <div class="content">
            <p>Hello,</p>
            <p>Thank you for registering with TURO. Please use the following One-Time Password (OTP) to complete your email verification process. This OTP is valid for 10 minutes.</p>
            <div class="otp-container">
              <div class="otp-code">${otp}</div>
            </div>
            <p>If you did not request this verification, please disregard this email.</p>
          </div>
          <div class="footer">
            <p>&copy; 2025 TURO. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
      `,
    };

    const transporter = getTransporter();
    await transporter.sendMail(mailOptions);
    console.log("📧 OTP email sent successfully");
    return { success: true, message: "OTP sent successfully." };
  } catch (error) {
    console.error("⚠️ Error sending OTP email:", error);
    throw new functions.https.HttpsError("internal", "Failed to send OTP email.", error);
  }
});

/**
 * A callable Cloud Function to verify an OTP and create a custom auth token.
 * It checks the provided OTP against the one stored in Firestore. If valid,
 * it creates a Firebase user (if one doesn't exist) and returns a custom
* token for the client to sign in with.
 */
export const verifyEmailOTP = functions.https.onCall(async (request) => {
    const data = request.data as VerifyEmailOTPData;
    const email = data['email'];
    const otp = data['otp'];
    
    // Validate input
    if (!email || !otp) {
        throw new functions.https.HttpsError("invalid-argument", "Email and OTP are required.");
    }

    const otpDocRef = db.collection("otps").doc(email);
    const otpDoc = await otpDocRef.get();
    const otpData = otpDoc.data();
    // Check if OTP document exists
    if (!otpDoc.exists) {
        throw new functions.https.HttpsError("not-found", "OTP not found. It may have expired or never existed."); 
    }

    
    if (!otpData) {
        throw new functions.https.HttpsError("internal", "Could not retrieve OTP data.");
    }

    // Check for expiration
    if (otpData.expires.toDate() < new Date()) {
        await otpDocRef.delete(); // Clean up expired OTP
        throw new functions.https.HttpsError("deadline-exceeded", "The OTP has expired. Please request a new one.");
    }

    // Check if OTP matches
    if (otpData.otp !== otp) {
        throw new functions.https.HttpsError("permission-denied", "The OTP is incorrect.");
    }

    // If valid, delete the OTP so it can't be reused
    await otpDocRef.delete();

    // Get an existing user or create a new one
    let userRecord;
    try {
        userRecord = await admin.auth().getUserByEmail(email);
    } catch (e) {
        const error = e as { code: string };
        if (error.code === "auth/user-not-found") {
            // Create a new user if one doesn't exist
            userRecord = await admin.auth().createUser({ email: email });
        } else {
            // For other errors, rethrow
            throw new functions.https.HttpsError("internal", "Error retrieving user account.");
        }
    }

    // Generate a custom token for the user to sign in with
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    // Return the token to the client
    return { success: true, token: customToken };
});

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// Import and export admin analytics functions (organized by feature)
export * as adminAnalytics from "./admin/analytics";

/**
 * A callable Cloud Function to save a user's profile data.
 * It connects to the named 'turo' database and saves the data provided
 * by the authenticated user using the new 3-Layer Schema.
 * 
 * DEPRECATED: This function uses the old schema. Consider refactoring to use
 * the new 3-Layer Schema with 'users' and 'user_details' collections.
 */
export const saveUserProfile = functions.https.onCall(async (request) => {
  // Ensure the user is authenticated.
  if (!request.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  // Initialize a separate Firestore instance for the 'turo' database.
  const turoDb = admin.firestore();
  turoDb.settings({ databaseId: 'turo' });

  const uid = request.auth.uid;
  const data = request.data;

  // Validate that data exists
  if (!data || typeof data !== 'object') {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Profile data is required."
    );
  }

  // Create a new object with the client data and server-side additions.
  const profileToSave = {
    ...data,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    email: request.auth.token.email || null,
  };

  try {
    // WARNING: Using old schema 'user_profiles' collection
    // TODO: Refactor to use new 3-Layer Schema:
    // - 'users' collection for public data
    // - 'user_details' collection for private data
    await turoDb
      .collection("user_profiles")
      .doc(uid)
      .set(profileToSave, { merge: true });

    console.log(`✅ Successfully saved profile for user: ${uid}`);
    return { success: true, message: "Profile saved successfully." };
  } catch (error) {
    console.error(`❌ Error saving user profile for ${uid}:`, error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while saving the profile."
    );
  }
});

// ========== Admin Module Functions ==========
// Export all admin-related Cloud Functions
export {onUserVerified, resetDailyStats} from "./admin/dashboard_stats";
