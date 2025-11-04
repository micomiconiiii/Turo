import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
import {defineString} from "firebase-functions/params";

// Define email and password as environment variables
const emailProvider = defineString("EMAIL");
const passwordProvider = defineString("PASSWORD");


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

// Configure Nodemailer
const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
        user: emailProvider.value(),
        pass: passwordProvider.value(),
    },
});

/**
 * A callable Cloud Function to request an OTP for a given email address.
 * It generates a 6-digit OTP, saves it to Firestore with a 10-minute expiry,
 * and sends it to the user's email.
 */
export const requestEmailOTP = functions.https.onCall(async (request) => {
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

    // Send the email
    try {
        console.log(`Attempting to send email from: ${emailProvider.value()}`);
        const mailOptions = {
            from: emailProvider.value(),
            to: email,
            subject: "Your OTP for Email Verification",
            text: `Your OTP is ${otp}`,
        };

        const info = await transporter.sendMail(mailOptions);
        console.log("Email sent: " + info.response);
        return { success: true, message: "OTP sent successfully." };
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

    console.log(`Verifying OTP for email: ${email} with OTP: ${otp}`);

    // Validate input
    if (!email || !otp) {
        throw new functions.https.HttpsError("invalid-argument", "Email and OTP are required.");
    }

    const otpDocRef = db.collection("otps").doc(email);
    const otpDoc = await otpDocRef.get();

    // Check if OTP document exists
    if (!otpDoc.exists) {
        console.log("OTP document not found.");
        throw new functions.https.HttpsError("not-found", "OTP not found. It may have expired or never existed.");
    }

    const otpData = otpDoc.data();

    if (!otpData) {
        console.log("Could not retrieve OTP data.");
        throw new functions.https.HttpsError("internal", "Could not retrieve OTP data.");
    }

    // Check for expiration
    if (otpData.expires.toDate() < new Date()) {
        await otpDocRef.delete(); // Clean up expired OTP
        console.log("OTP expired.");
        throw new functions.https.HttpsError("deadline-exceeded", "The OTP has expired. Please request a new one.");
    }

    // Check if OTP matches
    if (otpData.otp !== otp) {
        console.log("Incorrect OTP.");
        throw new functions.https.HttpsError("permission-denied", "The OTP is incorrect.");
    }

    console.log("OTP verified successfully.");

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
            console.log("User not found, creating a new one.");
            userRecord = await admin.auth().createUser({ email: email });
        } else {
            // For other errors, rethrow
            console.error("Error getting user:", e);
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
