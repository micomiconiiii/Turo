# Anonymous Authentication Setup

## ✅ What was added

### Firebase Anonymous Auth
Anonymous authentication has been integrated into your app to provide temporary user IDs without requiring sign-up/login.

### Changes made:

**1. `lib/main.dart`**
- Added `firebase_auth` import
- Added anonymous sign-in logic in `main()` function before `runApp()`
- Now automatically creates an anonymous user on first launch

```dart
// Sign in anonymously if no user is currently authenticated
if (FirebaseAuth.instance.currentUser == null) {
  await FirebaseAuth.instance.signInAnonymously();
  debugPrint('Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}');
}
```

**2. `lib/mentee-onboarding/confirmation_step.dart`**
- Already updated to use `FirebaseAuth.instance.currentUser!.uid`
- Uses `DatabaseService` with typed models
- Performs atomic batch write to Firestore

## How it works

### On app startup:
1. Firebase initializes
2. Checks if a user is signed in
3. If not → signs in anonymously and gets a unique user ID
4. The anonymous UID persists across app restarts (stored locally)

### During onboarding:
1. User fills out all onboarding steps
2. On "Confirm & Finish", the app:
   - Gets the anonymous user's UID
   - Creates `UserProfileModel` and `MenteeProfileModel`
   - Saves both to Firestore using `DatabaseService.createMenteeOnboardingData()`
   - Data is stored in two collections:
     - `user_profiles/{userId}` - Personal info
     - `mentee_profiles/{userId}` - Learning preferences

### Anonymous vs Real Auth

**Anonymous users:**
- ✅ Get a unique, persistent user ID
- ✅ Can save and retrieve data
- ✅ No password or email required
- ⚠️ If user uninstalls app or clears data, they lose access to their account
- ⚠️ Cannot access data from other devices

**Upgrading to real auth later:**
You can convert anonymous users to permanent accounts:

```dart
// Link email/password to anonymous account
final credential = EmailAuthProvider.credential(
  email: email,
  password: password,
);
await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

// Or link with Google, Facebook, etc.
final googleCredential = await GoogleAuthProvider().signIn();
await FirebaseAuth.instance.currentUser!.linkWithCredential(googleCredential);
```

## Testing

### Run the app:
```powershell
flutter run
```

### What to expect:
1. App launches → Anonymous sign-in happens automatically
2. Check debug console: You'll see `Signed in anonymously: [user-id]`
3. Complete onboarding flow
4. Tap "Confirm & Finish"
5. Data saves to Firestore under the anonymous user's ID

### Verify in Firebase Console:
1. Go to **Authentication** → Users tab
   - You'll see an anonymous user (no email, method: "Anonymous")
2. Go to **Firestore Database** → Data tab
   - Collections: `user_profiles` and `mentee_profiles`
   - Each document ID matches the anonymous user's UID

## Security rules (important!)

Update your Firestore rules to scope anonymous users to their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles - users can only read/write their own profile
    match /user_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Mentee profiles - users can only read/write their own profile
    match /mentee_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

This ensures:
- ✅ Authenticated users (including anonymous) can access their own data
- ❌ Users cannot read or modify other users' data
- ❌ Unauthenticated requests are rejected

## Production considerations

For a production app, consider:

1. **Add real authentication** - Email/password, Google, Apple, etc.
2. **Link anonymous accounts** - Let users upgrade to permanent accounts
3. **Handle auth state changes** - Show login screen if user signs out
4. **Add account recovery** - For non-anonymous users
5. **Data migration** - If users want to merge anonymous data with a new account

## Next steps

- ✅ Anonymous auth is ready to use
- ✅ Onboarding saves to Firestore with user ID
- 📋 TODO: Update Firestore security rules (see above)
- 📋 TODO: Add real authentication later
- 📋 TODO: Create a home screen route (currently navigates to '/home')

---

**Summary**: Your app now automatically signs in users anonymously on launch. They can complete onboarding and their data will be saved to Firestore with a unique user ID. No login screen required for testing!
