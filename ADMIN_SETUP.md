# Admin User Setup Guide

## Creating Your First Admin User

Since the Admin Portal requires a user with the `admin` role, you need to create one first. Here are two methods:

### Method 1: Using Firebase Console (Recommended)

1. **Create the Auth User:**
   - Go to Firebase Console → Authentication → Users
   - Click "Add User"
   - Enter email: `admin@turo.com` (or your preferred email)
   - Enter a secure password
   - Copy the generated User UID

2. **Create the Firestore Document:**
   - Go to Firebase Console → Firestore Database
   - Navigate to the `users` collection
   - Click "Add Document"
   - Use the User UID from step 1 as the Document ID
   - Add these fields:
     ```
     email: "admin@turo.com"
     display_name: "Admin User"
     roles: ["admin"]  // Array with "admin" string
     created_at: [Current Timestamp]
     is_verified: true
     ```

3. **Test Login:**
   - Run the app: `flutter run -d chrome`
   - Use the email and password you set

### Method 2: Using a Signup Script (Quick)

You can temporarily allow admin signup by creating a test user through the regular flow, then manually updating Firestore:

1. **Sign up as a regular user** (mentor or mentee)
2. **Go to Firestore Console**
3. **Find your user document** in the `users` collection
4. **Edit the `roles` field:**
   - Change from `["mentor"]` or `["mentee"]`
   - To `["admin"]` or `["admin", "mentor"]` (if you want both roles)
5. **Save and try logging in** to the Admin Portal

### Method 3: Create Admin via Code (Development Only)

Add this temporary code to `main.dart` (remove after creating admin):

```dart
// TEMPORARY: Create first admin user (remove after setup)
Future<void> _createAdminUser() async {
  try {
    final authService = AuthService();
    final user = await authService.signUpWithEmailPassword(
      'admin@turo.com',
      'YourSecurePassword123!',
      'Admin User',
      'admin',  // This will be ignored by createInitialUser
    );
    
    if (user != null) {
      // Manually update the roles to include 'admin'
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'roles': ['admin'],
          'is_verified': true,
        });
      
      print('✅ Admin user created successfully: ${user.email}');
    }
  } catch (e) {
    print('❌ Error creating admin: $e');
  }
}
```

Call this once in `main()` before `runApp()`, then remove it.

## Security Notes

⚠️ **Important Security Practices:**

1. **Use a strong password** for admin accounts (16+ characters, mixed case, numbers, symbols)
2. **Enable 2FA** on the email account associated with admin access
3. **Never commit** admin credentials to version control
4. **Rotate passwords** regularly (every 90 days)
5. **Limit admin users** to only those who absolutely need access
6. **Audit logs** - Consider adding admin action logging to Firestore

## Troubleshooting

### "Invalid email address" error
- Make sure email doesn't have leading/trailing spaces
- Use lowercase letters
- Follow standard email format: `user@domain.com`

### "Access Denied" message after login
- Check Firestore: user document must have `roles: ["admin"]`
- The roles field must be an **array**, not a string
- Make sure `is_verified` is `true` (optional but recommended)

### "User not found" error
- User exists in Authentication but not in Firestore
- Run signup flow OR manually create Firestore document

## Test Credentials (Development Only)

For local testing, you can use:
- Email: `admin@turo.test`
- Password: `Admin123!Test`

**⚠️ Delete this user before deploying to production!**
