# Firebase Storage Setup for Profile Pictures

## Issue
You're getting a **403 Unauthorized** error when uploading profile pictures because Firebase Storage security rules are not configured.

## Solution: Update Firebase Storage Rules

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com
   - Select your project: `turo-31805`

2. **Navigate to Storage Rules**
   - Click on **Storage** in the left sidebar
   - Click on the **Rules** tab at the top

3. **Update the Rules**
   Replace the existing rules with this:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload/read/write their own profile pictures
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

4. **Publish the Rules**
   - Click the **Publish** button

## What This Does

- **Read Access**: Any authenticated user can view profile pictures
- **Write Access**: Users can only upload/modify/delete their own profile pictures (matching their user ID)
- **Security**: Prevents unauthorized access and ensures users can't mess with other users' photos

## Changes Made to Fix Your Issues

### 1. File Resets on Back Navigation ✅
**Problem**: When you went back to the profile picture step, the selected image disappeared.

**Solution**: Added state restoration using the provider:
- Profile picture data is now saved to `MenteeOnboardingProvider` when selected
- On page init, the step checks the provider and restores the image
- Works for both mobile (File) and web (Uint8List)

### 2. Upload Timing Changed ✅
**Problem**: Image was uploading immediately when clicking "Next", before you could review on the confirmation screen.

**Solution**: Moved upload to confirmation step:
- Clicking "Next" on profile picture step now just saves the image data locally
- Upload happens when you click "Confirm & Finish"
- This matches the flow of other onboarding data (review first, then save)

### 3. Fixed 403 Error (Requires Firebase Rules Update) ⚠️
**Problem**: `[firebase_storage/unauthorized] User is not authorized to perform the desired action`

**Solution**: You need to update Firebase Storage rules (see above)
- Anonymous auth users need permission to write to storage
- The rules above grant proper permissions

## Testing Steps

1. **Update Firebase Storage rules** (see above)
2. **Run the app**: `flutter run -d chrome` (or your preferred device)
3. **Navigate to profile picture step**
4. **Select an image** from gallery or take a photo
5. **Click Back** - verify image is still there
6. **Click Next** - verify no upload happens yet
7. **Review on confirmation screen** - verify image preview shows
8. **Click "Confirm & Finish"** - verify upload succeeds
9. **Check Firebase Console** → Storage → `profile_pictures/{userId}/profile.jpg` should exist

## File Changes Summary

| File | Changes |
|------|---------|
| `provider_storage/storage.dart` | Added temporary fields for File/Uint8List before upload |
| `profile_picture_step.dart` | Saves to provider, restores on init, removed upload logic |
| `confirmation_step.dart` | Added upload logic before saving to Firestore |
| `mentee_onboarding_page.dart` | Simplified profile picture step validation |
