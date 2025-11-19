# Firebase Storage CORS and Content Type Configuration

## Problems and Solutions

### Problem 1: Files Stored with Wrong MIME Type
Files uploaded to Firebase Storage are stored as `application/octet-stream` instead of `image/jpeg`.

**Solution:** ✅ **FIXED** - The `StorageService` now automatically sets the correct content type based on file extension. For web uploads, the content type is explicitly set in `confirmation_step.dart`.

### Problem 2: CORS Error on Web
Getting `ERR_FAILED 200 (OK)` or CORS policy errors when loading images from Firebase Storage on web.

## Solution for CORS

### Step 1: Verify Storage Rules
Ensure your Firebase Storage rules allow authenticated reads:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 2: Configure CORS (if needed)

If the error persists, configure CORS using Google Cloud SDK:

```powershell
# Install Google Cloud SDK first
# https://cloud.google.com/sdk/docs/install

# Apply CORS configuration to your bucket
gsutil cors set cors.json gs://turo-31805.firebasestorage.app
```

### Step 3: Verify CORS Configuration

```powershell
# Check current CORS settings
gsutil cors get gs://turo-31805.firebasestorage.app
```

## Alternative: Handle Image Loading Errors Gracefully

If CORS configuration is not immediately possible, add error handling to your NetworkImage:

```dart
CircleAvatar(
  radius: 48,
  backgroundImage: NetworkImage(profilePictureUrl),
  onBackgroundImageError: (exception, stackTrace) {
    debugPrint('Failed to load profile picture: $exception');
  },
)
```

Or use `Image.network` with an `errorBuilder`:

```dart
ClipOval(
  child: Image.network(
    profilePictureUrl,
    width: 96,
    height: 96,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.person, size: 48);
    },
  ),
)
```
