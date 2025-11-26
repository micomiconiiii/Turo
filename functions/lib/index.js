"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveUserProfile = exports.helloWorld = exports.verifyEmailOTP = exports.requestEmailOTP = void 0;
const functions = __importStar(require("firebase-functions"));
const https_1 = require("firebase-functions/v2/https");
const nodemailer = __importStar(require("nodemailer"));
const params_1 = require("firebase-functions/params");
const firebase_1 = __importStar(require("./services/firebase"));
const crypto_1 = require("crypto");
// Define email and password as environment variables
const emailProvider = (0, params_1.defineString)("EMAIL");
const passwordProvider = (0, params_1.defineString)("PASSWORD");
console.log("Email used:", emailProvider.value());
console.log("Password length:", (_a = passwordProvider.value()) === null || _a === void 0 ? void 0 : _a.length);
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
exports.requestEmailOTP = functions.https.onCall(async (request) => {
    const data = request.data;
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
    await firebase_1.turoDb.collection("otps").doc(email).set(otpDoc);
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
        await transporter.sendMail(mailOptions);
        console.log("📧 OTP email sent successfully");
        return { success: true, message: "OTP sent successfully." };
    }
    catch (error) {
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
exports.verifyEmailOTP = functions.https.onCall(async (request) => {
    const data = request.data;
    const email = data['email'];
    const otp = data['otp'];
    // Validate input
    if (!email || !otp) {
        throw new functions.https.HttpsError("invalid-argument", "Email and OTP are required.");
    }
    const otpDocRef = firebase_1.turoDb.collection("otps").doc(email);
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
        userRecord = await firebase_1.auth.getUserByEmail(email);
    }
    catch (e) {
        const error = e;
        if (error.code === "auth/user-not-found") {
            // Create a new user if one doesn't exist
            userRecord = await firebase_1.auth.createUser({ email: email });
        }
        else {
            // For other errors, rethrow
            throw new functions.https.HttpsError("internal", "Error retrieving user account.");
        }
    }
    // Generate a custom token for the user to sign in with
    const customToken = await firebase_1.auth.createCustomToken(userRecord.uid);
    // Return the token to the client
    return { success: true, token: customToken };
});
exports.helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send("Hello from Firebase!");
});
/**
 * A callable Cloud Function to save a user's profile data.
 * It connects to the named 'turo' database and saves the data provided
 * by the authenticated user.
 */
exports.saveUserProfile = (0, https_1.onCall)({
    memory: "1GiB", // Increase memory to fix the crash
    timeoutSeconds: 300, // Increase timeout for large uploads
    cors: true // Enable CORS if needed
}, async (request) => {
    if (!request.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    const uid = request.auth.uid;
    const data = request.data;
    // Log the entire data object for debugging
    console.log('Received data:', JSON.stringify(data, null, 2));
    const user = data.user || {};
    const userDetail = data.userDetail || {};
    // Helper: recursively convert numeric/string date-like fields to Firestore Timestamps
    const convertTimestampsRecursively = (obj) => {
        if (!obj || typeof obj !== 'object')
            return obj;
        if (Array.isArray(obj)) {
            return obj.map((v) => convertTimestampsRecursively(v));
        }
        for (const key of Object.keys(obj)) {
            const val = obj[key];
            if (val == null)
                continue;
            // If it's already a Firestore Timestamp leave it
            if (val instanceof firebase_1.default.firestore.Timestamp)
                continue;
            // Keys that are likely timestamp/date fields
            const lowerKey = key.toLowerCase();
            const looksLikeDateKey = lowerKey.includes('date') || lowerKey.includes('created') || lowerKey.includes('expires') || lowerKey.includes('time');
            if (looksLikeDateKey) {
                if (typeof val === 'number') {
                    try {
                        obj[key] = firebase_1.default.firestore.Timestamp.fromMillis(val);
                        continue;
                    }
                    catch (e) {
                        console.warn(`Could not convert number to Timestamp for key=${key}`, e);
                    }
                }
                if (typeof val === 'string') {
                    const parsed = Date.parse(val);
                    if (!isNaN(parsed)) {
                        obj[key] = firebase_1.default.firestore.Timestamp.fromDate(new Date(parsed));
                        continue;
                    }
                }
            }
            // Recurse into nested objects/arrays
            if (typeof val === 'object') {
                convertTimestampsRecursively(val);
            }
        }
        return obj;
    };
    // Sanity-check payloads and convert timestamps for both user and userDetail (and nested fields)
    if (user && typeof user === 'object') {
        convertTimestampsRecursively(user);
    }
    if (userDetail && typeof userDetail === 'object') {
        convertTimestampsRecursively(userDetail);
    }
    // Add the email to the userDetail object
    // userDetail.email = request.auth.token.email || null;
    // We'll upload any provided base64 files to Cloud Storage using the Admin SDK
    // so the client doesn't need storage permissions. Collect resulting URLs and
    // then write Firestore documents in a batch.
    const bucket = firebase_1.default.storage().bucket();
    let selfieUrl = null;
    let idFileUrl = null;
    // Upload selfie if included
    if (data.selfieBase64 && data.selfieFileName) {
        try {
            const selfieBuffer = Buffer.from(data.selfieBase64, 'base64');
            const selfiePath = `users/${uid}/selfie/${data.selfieFileName}`;
            const selfieToken = (0, crypto_1.randomUUID)();
            const file = bucket.file(selfiePath);
            await file.save(selfieBuffer, {
                metadata: {
                    contentType: 'image/jpeg',
                    metadata: { firebaseStorageDownloadTokens: selfieToken },
                },
            });
            const bucketName = bucket.name;
            selfieUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(selfiePath)}?alt=media&token=${selfieToken}`;
            // Also put on user object if desired
            user.profile_picture_url = selfieUrl;
        }
        catch (e) {
            console.error('Error uploading selfie to Storage:', e);
            // proceed but log
        }
    }
    // Upload ID file if included
    if (data.idBase64 && data.idFileName) {
        try {
            const idBuffer = Buffer.from(data.idBase64, 'base64');
            const idPath = `users/${uid}/id_verification/${data.idFileName}`;
            const idToken = (0, crypto_1.randomUUID)();
            const file = bucket.file(idPath);
            await file.save(idBuffer, {
                metadata: {
                    contentType: 'application/octet-stream',
                    metadata: { firebaseStorageDownloadTokens: idToken },
                },
            });
            const bucketName = bucket.name;
            idFileUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(idPath)}?alt=media&token=${idToken}`;
        }
        catch (e) {
            console.error('Error uploading ID file to Storage:', e);
        }
    }
    // Process credentials and achievements: upload any certificates and map to URLs
    const credentialsIn = Array.isArray(data.credentials) ? data.credentials : [];
    const achievementsIn = Array.isArray(data.achievements) ? data.achievements : [];
    const credentialsOut = [];
    for (const cred of credentialsIn) {
        const out = { title: cred.title || null, year: cred.year || null };
        if (cred.certificateBase64 && cred.certificateFileName) {
            try {
                const certBuffer = Buffer.from(cred.certificateBase64, 'base64');
                const certPath = `users/${uid}/credentials/${cred.certificateFileName}`;
                const certToken = (0, crypto_1.randomUUID)();
                const file = bucket.file(certPath);
                await file.save(certBuffer, {
                    metadata: {
                        contentType: 'application/octet-stream',
                        metadata: { firebaseStorageDownloadTokens: certToken },
                    },
                });
                const bucketName = bucket.name;
                out.certificateUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(certPath)}?alt=media&token=${certToken}`;
            }
            catch (e) {
                console.error('Error uploading credential certificate:', e);
                out.certificateUrl = null;
            }
        }
        credentialsOut.push(out);
    }
    const achievementsOut = [];
    for (const ach of achievementsIn) {
        const out = { title: ach.title || null, year: ach.year || null };
        if (ach.certificateBase64 && ach.certificateFileName) {
            try {
                const certBuffer = Buffer.from(ach.certificateBase64, 'base64');
                const certPath = `users/${uid}/achievements/${ach.certificateFileName}`;
                const certToken = (0, crypto_1.randomUUID)();
                const file = bucket.file(certPath);
                await file.save(certBuffer, {
                    metadata: {
                        contentType: 'application/octet-stream',
                        metadata: { firebaseStorageDownloadTokens: certToken },
                    },
                });
                const bucketName = bucket.name;
                out.certificateUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(certPath)}?alt=media&token=${certToken}`;
            }
            catch (e) {
                console.error('Error uploading achievement certificate:', e);
                out.certificateUrl = null;
            }
        }
        achievementsOut.push(out);
    }
    // Now write Firestore documents in a batch using the 'Turo' database
    const batch = firebase_1.turoDb.batch();
    const userRef = firebase_1.turoDb.collection('users').doc(uid);
    // merge user to include profile_picture_url if set
    batch.set(userRef, user, { merge: true });
    const userDetailRef = firebase_1.turoDb.collection('user_details').doc(uid);
    batch.set(userDetailRef, userDetail, { merge: true });
    const mentorData = {
        user_id: uid,
        id_type: data.idType || null,
        id_file_name: data.idFileName || null,
        id_file_url: idFileUrl || null,
        selfie_url: selfieUrl || null,
        verification_status: 'pending',
        institutional_email: data.institutionalEmail || null,
        updated_at: firebase_1.default.firestore.FieldValue.serverTimestamp(),
    };
    if (credentialsOut.length > 0) {
        mentorData.credentials = firebase_1.default.firestore.FieldValue.arrayUnion(...credentialsOut);
    }
    if (achievementsOut.length > 0) {
        mentorData.achievements = firebase_1.default.firestore.FieldValue.arrayUnion(...achievementsOut);
    }
    const mentorRef = firebase_1.turoDb.collection('mentor_profile').doc(uid);
    batch.set(mentorRef, mentorData, { merge: true });
    try {
        await batch.commit();
        console.log(`✅ Successfully saved profile for user: ${uid}`);
        return { success: true, message: "Profile saved successfully." };
    }
    catch (error) {
        console.error(`❌ Error saving user profile for ${uid}:`, error);
        throw new functions.https.HttpsError("internal", "An error occurred while saving the profile.");
    }
});
//# sourceMappingURL=index.js.map