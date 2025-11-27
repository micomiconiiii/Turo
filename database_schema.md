
# Firestore Database Schema for Turo

This document outlines the database schema for the Turo project using Firebase Firestore, with a dedicated collection for mentor verification data.

## Data Model

The database is structured to separate general user information from sensitive mentor-specific data.

### 1. `user_profiles` collection

This collection stores general information for all users, both mentors and mentees.

-   **Document ID:** `uid` (User ID from Firebase Authentication)
-   **Fields:**
    -   `fullName`: (String)
    -   `birthdate`: (Timestamp)
    -   `bio`: (String)
    -   `address`: (Map)
        -   `unitBldg`: (String)
        -   `street`: (String)
        -   `barangay`: (String)
        -   `city`: (String)
        -   `province`: (String)
        -   `zipCode`: (String)
    -   `email`: (String) The user's email address.
    -   `createdAt`: (Timestamp) The timestamp when the user account was created.
    -   `roles`: (Array) An array of strings representing user roles (e.g., `['mentee', 'mentor']`).

### 2. `mentor_verifications` collection

This collection is solely for mentor-related data, including verification and credentials. Each document is linked to a user in the `user_profiles` collection via the UID.

-   **Document ID:** `uid` (User ID from Firebase Authentication)
-   **Fields:**
    -   `verification`: (Map)
        -   `idUrl`: (String) URL of the uploaded ID document.
        -   `selfieUrl`: (String) URL of the selfie image.
        -   `status`: (String) Verification status (e.g., 'pending', 'verified', 'rejected').
    -   `institutionalVerification`: (Map)
        -   `institutionName`: (String)
        -   `status`: (String) Verification status.
    -   `expertise`: (Array) A list of strings representing the mentor's areas of expertise.

-   **Sub-collection: `achievements`**
    -   **Document ID:** Auto-generated ID.
    -   **Fields:**
        -   `title`: (String)
        -   `description`: (String)
        -   `date`: (Timestamp)
        -   `proofUrl`: (String) URL to any proof document.

### 3. `cities` collection

This collection can be pre-populated from your `assets/cities.json` file.

-   **Document ID:** Auto-generated ID.
-   **Fields:**
    -   `name`: (String)
    -   `country`: (String)

## Firestore Security Rules

Here are the updated security rules for this schema:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read and update their own profile.
    match /user_profiles/{userId} {
      allow read, update: if request.auth.uid == userId;
      allow create: if request.auth.uid != null;
    }

    // Mentor verification data can only be accessed by the mentor themselves.
    match /mentor_verifications/{userId} {
      allow read, create, update: if request.auth.uid == userId;
    }

    // Achievements can only be managed by the mentor.
    match /mentor_verifications/{userId}/achievements/{achievementId} {
        allow read, create, update, delete: if request.auth.uid == userId;
    }

    // Cities can be read by any authenticated user.
    match /cities/{cityId} {
      allow read: if request.auth.uid != null;
    }
  }
}
```
