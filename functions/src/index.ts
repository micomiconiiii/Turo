import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as sgMail from "@sendgrid/mail";
import {defineString} from "firebase-functions/params";

// Define parameters for environment variables
const sendgridApiKey = defineString("SENDGRID_API_KEY");
const senderEmail = defineString("SENDER_EMAIL");

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

/**
 * A callable Cloud Function to request an OTP for a given email address.
 * It generates a 6-digit OTP, saves it to Firestore with a 10-minute expiry,
 * and sends it to the user's email using SendGrid.
 */
export const requestEmailOTP = functions.https.onCall(async (request) => {
    sgMail.setApiKey(sendgridApiKey.value());

    const data = request.data as RequestEmailOTPData;
    const email = data['email'];

    // Validate input
    if (!email || !/\S+@\S+\.\S+/.test(email)) {
        throw new functions.https.HttpsError("invalid-argument", "A valid email address is required.");
    }

    // Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiration = new Date(Date.now() + 10 * 60 * 1000); // 10-minute expiration

    // Save the OTP and its expiration to Firestore
    const otpDoc = {
        email: email,
        otp: otp,
        expires: expiration,
    };
    await db.collection("otps").doc(email).set(otpDoc);

    // Define email content for SendGrid
    const msg = {
        to: email,
        from: {
            name: "Turo",
            email: senderEmail.value(),
        },
        subject: "Your One-Time Password",
        html: `
          <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
              <h2 style="text-align: center; color: #444;">Your One-Time Password</h2>
              <p>Hello,</p>
              <p>Please use the following One-Time Password (OTP) to complete your action. This OTP is valid for 10 minutes.</p>
              <div style="text-align: center; margin: 20px 0;">
                <span style="display: inline-block; padding: 10px 20px; background-color: #f0f0f0; border-radius: 5px; font-size: 24px; letter-spacing: 5px; font-weight: bold;">
                  ${otp}
                </span>
              </div>
              <p>If you did not request this OTP, please ignore this email.</p>
              <p>Thanks,<br>The Turo Team</p>
            </div>
          </div>
        `,
    };

    // Send the email
    try {
        await sgMail.send(msg);
        return { success: true, message: "OTP has been sent to your email address." };
    } catch (error) {
        console.error("Error sending OTP email:", error);
        throw new functions.https.HttpsError("internal", "Failed to send OTP email. Please try again later.", error);
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

    // Check if OTP document exists
    if (!otpDoc.exists) {
        throw new functions.https.HttpsError("not-found", "OTP not found. It may have expired or never existed.");
    }

    const otpData = otpDoc.data();

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
    return { token: customToken };
});

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});