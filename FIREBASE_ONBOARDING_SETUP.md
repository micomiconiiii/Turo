# Mentee Onboarding → Firebase Integration

## Overview
The mentee onboarding flow now saves user input directly to **Cloud Firestore** in the `mentee_onboarding` collection. This works **without user authentication** for feature development—each submission creates a new document with an auto-generated ID.

## What was added

### 1. Dependencies
- `cloud_firestore` (already installed)
- `firebase_core` (already initialized in `lib/main.dart`)

### 2. Service Layer
**File**: `lib/services/mentee_onboarding_service.dart`

- `saveMenteeOnboarding(provider, {userId})`: Saves all onboarding data from `MenteeOnboardingProvider` to Firestore.
  - Collection: `mentee_onboarding`
  - Document ID: Auto-generated (or pass a custom `userId` once auth is added)
  - Fields: fullName, birthMonth, birthDay, birthYear, bio, address, addressDetails, interests, goals, duration, minBudget, maxBudget, createdAt, updatedAt

- `getMenteeOnboarding(docId)`: Retrieves a single record by document ID (optional helper).
- `streamAllMenteeOnboarding()`: Streams all records, useful for admin dashboards (optional helper).

### 3. UI Update
**File**: `lib/mentee-onboarding/confirmation_step.dart`

- Converted to `StatefulWidget` to handle async save operation.
- "Confirm & Finish" button now:
  - Shows a loading spinner while saving
  - Displays a green success snackbar with the document ID
  - Displays a red error snackbar if the save fails
  - Disables the button during save to prevent duplicate submissions

## How to test

### Step 1: Enable Firestore in Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **turo-31805**
3. Go to **Build → Firestore Database**
4. If not already enabled, click "Create database"
5. Choose **Start in test mode** (allows all reads/writes for 30 days—good for dev)
6. Click "Next" → Choose a location (e.g., `us-central1`) → "Enable"

### Step 2: Set development Firestore rules (if needed)
If you chose "Start in production mode" or want to explicitly allow writes without auth:

1. In Firebase Console → Firestore → Rules tab
2. Replace with this **dev-only** ruleset:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes for development
    // WARNING: Remove or restrict this before deploying to production!
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. Click "Publish"

> **Security Note**: These rules allow anyone to read/write any document. Once you add Firebase Auth, replace `if true` with `if request.auth != null` and scope rules to user-owned documents.

### Step 3: Run the app
```powershell
flutter run
```

1. Complete the onboarding flow (all 5 steps).
2. On the confirmation screen, tap **"Confirm & Finish"**.
3. You should see:
   - A loading spinner briefly
   - A green snackbar: "Onboarding saved successfully! ID: [document-id]"
4. Check the console/debug output for the document ID.

### Step 4: Verify in Firebase Console
1. Go to Firestore Database → Data tab
2. You should see a new collection: `mentee_onboarding`
3. Expand it to see your submitted document with all fields populated.

## Production security (TODO)

Before deploying to production:

1. **Add Firebase Auth** (`dart pub add firebase_auth`)
2. **Update Firestore rules** to require authentication and scope writes:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /mentee_onboarding/{userId} {
      // Only the authenticated user can read/write their own onboarding data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. **Pass the user ID** when saving:
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  await _onboardingService.saveMenteeOnboarding(provider, userId: user.uid);
}
```

## Next steps (optional)
- Add Firebase Auth to create/login users before onboarding.
- Add Cloud Storage to upload profile images or documents.
- Build an admin dashboard to view/manage submitted onboarding data.
- Add validation rules in Firestore to enforce required fields and data types.

## Files modified/created
- ✅ `lib/services/mentee_onboarding_service.dart` (new)
- ✅ `lib/mentee-onboarding/confirmation_step.dart` (updated to call service)
- ✅ `pubspec.yaml` (cloud_firestore dependency added)
- ✅ `lib/main.dart` (Firebase initialized—already done)

---

**Summary**: Your onboarding data now persists to Firestore! Once you enable the database and set dev rules, tapping "Confirm & Finish" will save all inputs to the cloud. You can view them in the Firebase Console under the `mentee_onboarding` collection.
