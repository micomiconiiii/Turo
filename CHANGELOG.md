# Changelog - Turo App Development Session

## November 11, 2025

### 🎯 Major Features & Refactoring

#### 1. **User Authentication & Registration System Overhaul**

##### Email Verification System
- **Removed Firebase Auth's built-in email verification** (link-based) to avoid conflicts
- **Implemented custom OTP-based email verification** using Cloud Functions
- Created `CustomFirebaseOtpService` for OTP generation and validation
- OTP emails sent via nodemailer through Cloud Functions (`requestEmailOTP`, `verifyEmailOTP`, `resendEmailOTP`)
- 6-digit OTP with 10-minute expiration stored in Firestore `otps` collection

##### User Registration Flow
- **Added explicit role selection** in `UserRegistrationScreen` ("I'm a Mentee" / "I'm a Mentor" tabs)
- Removed broken heuristic-based role detection (was checking if fullName contains "mentor")
- Updated `AuthService.signUpWithEmailPassword()` to accept 4th parameter: `role` ('mentor' or 'mentee')
- User registration now correctly passes selected role to Firestore
- Added `emailVerificationScreen` route in `AppRoutes`

##### OTP Verification Screen Enhancement
- Made `OtpVerificationScreen` reusable for multiple purposes:
  - **Initial signup verification**: Routes based on user role (mentor → mentor registration, mentee → mentee onboarding)
  - **Institutional verification**: Custom callback to proceed to next step (ID Upload)
- Added optional `onVerificationSuccess` callback parameter
- Updated `institutional_verification_screen.dart` to pass custom navigation callback

#### 2. **User Data Model & Schema Standardization**

##### Field Naming Convention
- **Standardized all Firestore fields to snake_case**:
  - `displayName` → `display_name`
  - `createdAt` → `created_at`
  - `fullName` → `full_name`
  - `profilePictureUrl` → `profile_picture_url`
- Fixed duplicate field issue (was creating both camelCase and snake_case versions)

##### User Model Updates
- **Added `fullName` field** to user data model as required parameter
- Removed `username` field completely from UI and data model
- Updated `UserDetailModel` to include `fullName` field
- `AuthService` now accepts `fullName` parameter in signup
- `DatabaseService.createInitialUser()` refactored to 3-argument signature: `(uid, email, role)`
- Email prefix used as temporary displayName placeholder in `createInitialUser()`

#### 3. **Mentee Onboarding Feature**

##### Multi-Step Onboarding Flow
Created comprehensive mentee onboarding process with multiple steps:
1. **Welcome Step**: Introduction and overview
2. **Goals Step**: Select mentoring goals
3. **Interests Step**: Choose areas of interest
4. **Budget Step**: Set budget range (min/max)
5. **Duration Step**: Select preferred mentoring duration
6. **Personal Info Step**: Birthdate, address, phone number
7. **Profile Picture Step**: Upload or capture profile photo
8. **Confirmation Step**: Review and submit all information

##### State Management
- Created `MenteeOnboardingProvider` using Provider pattern
- Manages all onboarding state across steps
- Handles profile picture file/bytes for web and mobile
- Stores selections: goals, interests, budget, duration, personal details

##### Data Models
- Created `MenteeProfileModel` with:
  - Goals list
  - Interests list
  - Budget map (min/max)
  - Duration string
- `UserDetailModel` stores comprehensive user information:
  - userId, email, fullName
  - birthdate, address, phoneNumber
  - createdAt timestamp

##### UI Components
- Custom step indicator showing progress
- City field with typeahead/autocomplete functionality
- Address fields (Unit/Bldg, Street, Barangay, City, Postal Code)
- Profile picture upload with image picker (camera/gallery)
- Web support with bytes upload, mobile with file upload

#### 4. **Firebase Storage Service**

##### Storage Path Restructuring
- **Changed profile picture storage path**:
  - Old: `users/{userId}/profile_picture/profile.jpg`
  - New: `profile_pictures/{userId}/profile.jpg`
- Updated `StorageService.uploadProfilePicture()` method
- Fixed web upload path in `confirmation_step.dart` to match mobile path
- Updated code comments to reflect new path structure

##### Storage Security Rules
- **Created `storage.rules` file** with proper access control:
  - Users can only write to their own `profile_pictures/{userId}/` path
  - Read access for authenticated users
  - Deny all other paths by default
- Fixed 403 unauthorized errors during profile picture upload

#### 5. **Mentor Registration Flow**

##### Multi-Step Verification Process
Steps include:
1. Basic Information
2. **Institutional Verification** (sends OTP to institutional email)
3. ID Upload
4. Selfie Verification
5. Credentials & Achievements
6. Final Review

##### Institutional Verification
- Validates institutional email (blocks personal domains like gmail.com, yahoo.com)
- Sends OTP to verify institutional affiliation
- Stores institution name, institutional email, and job description
- Optional skip functionality
- Now correctly navigates to ID Upload screen after OTP verification

#### 6. **Database Service Refactoring**

##### Firestore Operations
- Centralized all Firestore operations in `DatabaseService`
- Uses named database `'turo'`
- Batch writes for atomic user creation
- **3-Layer Schema Implementation**:
  - `users` collection (public hub data)
  - `user_details` collection (private data)
  - Future: `mentor_verifications` collection

##### Methods
- `createInitialUser(uid, email, role)`: Creates both users and user_details docs
- `getUser(uid)`: Retrieves user document
- Uses `FieldValue.serverTimestamp()` for consistent timestamps

---

### 🐛 Bug Fixes

#### Authentication & Registration
1. **Fixed mentor role not being set during signup**
   - Was using broken heuristic checking fullName for "mentor" keyword
   - Now explicitly passes selected role from UI tabs

2. **Fixed duplicate email verification systems conflict**
   - Removed `user.sendEmailVerification()` from AuthService
   - Users were receiving both Firebase link AND custom OTP emails
   - Now only sends custom OTP via Cloud Functions

3. **Fixed duplicate Firestore fields**
   - Inconsistent naming caused both camelCase and snake_case versions
   - Standardized to snake_case across all services and models

4. **Fixed institutional OTP verification routing**
   - Was incorrectly trying to route based on role after institutional verification
   - Now uses custom callback to proceed to next step (ID Upload)

#### Storage & File Upload
1. **Fixed profile picture upload 403 error**
   - Missing Firebase Storage security rules
   - Created proper rules file with user-specific write access

2. **Fixed web/mobile path inconsistency**
   - Web was using old path `users/{uid}/profile_picture/profile.jpg`
   - Updated to match mobile path `profile_pictures/{uid}/profile.jpg`

#### Data Integrity
1. **Fixed wrong data in displayName field**
   - Was sometimes showing password or incorrect values
   - Now uses email prefix as placeholder until full name is provided

2. **Fixed missing fullName in mentee onboarding**
   - confirmation_step wasn't passing provider.fullName to UserDetailModel
   - Updated to include fullName from provider

3. **Fixed missing fullName in mentor registration**
   - Similar issue in mentor_registration_screen
   - Now passes _fullNameController.text to UserDetailModel

---

### 📁 Files Created

**New Files:**
- `lib/presentation/mentee_onboarding/pages/mentee_onboarding_page.dart`
- `lib/presentation/mentee_onboarding/providers/mentee_onboarding_provider.dart`
- `lib/presentation/mentee_onboarding/steps/welcome_step.dart`
- `lib/presentation/mentee_onboarding/steps/goals_step.dart`
- `lib/presentation/mentee_onboarding/steps/interests_step.dart`
- `lib/presentation/mentee_onboarding/steps/budget_step.dart`
- `lib/presentation/mentee_onboarding/steps/duration_step.dart`
- `lib/presentation/mentee_onboarding/steps/personal_info_step.dart`
- `lib/presentation/mentee_onboarding/steps/profile_picture_step.dart`
- `lib/presentation/mentee_onboarding/steps/confirmation_step.dart`
- `lib/models/mentee_profile_model.dart`
- `storage.rules` (Firebase Storage security rules)
- `CHANGELOG.md` (this file)

**Modified Files:**
- `lib/services/auth_service.dart` - Added role parameter, removed email verification
- `lib/services/database_service.dart` - Standardized to snake_case fields
- `lib/services/storage_service.dart` - Updated path structure and comments
- `lib/services/custom_firebase_otp_service.dart` - OTP implementation
- `lib/models/user_model.dart` - Snake_case field names
- `lib/models/user_detail_model.dart` - Added fullName field, snake_case
- `lib/presentation/user_registration_screen/user_registration_screen.dart` - Removed username, added role parameter, OTP sending
- `lib/presentation/mentor_registration_screen/otp_verification_screen.dart` - Added callback support for flexible navigation
- `lib/presentation/mentor_registration_screen/institutional_verification_screen.dart` - Custom callback for navigation
- `lib/presentation/mentor_registration_screen/mentor_registration_screen.dart` - Updated to pass fullName
- `lib/routes/app_routes.dart` - Added emailVerificationScreen and menteeOnboardingPage routes
- `lib/widgets/city_field.dart` - Typeahead component for city selection
- `functions/src/index.ts` - Cloud Functions for OTP (requestEmailOTP, verifyEmailOTP)

---

### 🔧 Technical Improvements

#### Code Quality
- Removed hardcoded TODO comments about replacing with explicit parameters (now implemented)
- Added comprehensive inline documentation
- Improved error handling with specific Firebase exception types
- Added loading states and user feedback (SnackBars, progress indicators)

#### Security
- Implemented Firebase Storage security rules
- Institutional email validation (blocks personal domains)
- OTP expiration (10 minutes)
- User-specific data access controls

#### User Experience
- Multi-step progress indicators
- Form validation with clear error messages
- Loading states during async operations
- Success/error feedback via SnackBars
- Profile picture preview before upload
- Skip options where appropriate (institutional verification)

#### Architecture
- Consistent snake_case naming convention
- Centralized service pattern (AuthService, DatabaseService, StorageService)
- Provider pattern for state management
- Reusable components (CustomButton, CustomEditText, CityField)
- Separation of concerns (services, models, presentation)

---

### 📋 Configuration Changes

**Firebase Configuration:**
- Storage rules added (deploy with `firebase deploy --only storage`)
- Cloud Functions for OTP email service
- Firestore collections: `users`, `user_details`, `otps`

**Email Service:**
- Using Gmail SMTP via nodemailer in Cloud Functions
- EMAIL and PASSWORD environment variables
- HTML email template with TURO branding
- 10-minute OTP expiration

---

### 🚀 Deployment Notes

**Required Steps:**
1. Deploy storage rules: `firebase deploy --only storage`
2. Deploy cloud functions: `firebase deploy --only functions`
3. Set Firebase Functions config (if not already set):
   ```
   firebase functions:config:set email="your-email@gmail.com"
   firebase functions:config:set password="your-app-password"
   ```

**Testing Checklist:**
- [ ] Mentee signup and OTP verification
- [ ] Mentor signup and OTP verification
- [ ] Mentee onboarding complete flow (all 8 steps)
- [ ] Mentor institutional verification with OTP
- [ ] Profile picture upload (web and mobile)
- [ ] Role-based routing after initial verification
- [ ] Institutional verification routing to ID upload

---

### 📝 Known Issues & Future Improvements

**Email Branding:**
- Currently sending from personal Gmail account
- Recommendation: Migrate to SendGrid, Mailgun, or AWS SES with custom domain
- Add SPF, DKIM, DMARC records for production

**Potential Enhancements:**
- Add is_verified flag update after successful OTP verification
- Implement OTP resend cooldown (30-60 seconds)
- Add file size and type validation for profile pictures
- Implement rate limiting for OTP requests
- Add scheduled cleanup for expired OTP documents
- Consider Firebase Extensions for email sending

**Pre-existing Issues (not addressed in this session):**
- LoginScreen.rememberMe field not final (immutable class warning)
- CustomImageView.imagePath field not final
- Unused exception variable in CustomFirebaseOtpService

---

### 👥 User Flows

**Mentee Registration & Onboarding:**
```
1. Sign Up (select "I'm a Mentee", enter email/password)
   ↓
2. OTP sent to email
   ↓
3. Enter OTP code (6 digits)
   ↓
4. Verify → Route to Mentee Onboarding
   ↓
5. Complete 8-step onboarding:
   - Welcome
   - Goals selection
   - Interests selection
   - Budget range
   - Duration preference
   - Personal info (birthdate, address, phone)
   - Profile picture upload
   - Confirmation & submit
   ↓
6. All data saved to Firestore (users + user_details collections)
```

**Mentor Registration & Verification:**
```
1. Sign Up (select "I'm a Mentor", enter email/password)
   ↓
2. OTP sent to email
   ↓
3. Enter OTP code
   ↓
4. Verify → Route to Mentor Registration
   ↓
5. Basic info (fullName, birthdate, address, phone)
   ↓
6. Institutional Verification:
   - Enter institution/organization
   - Enter institutional email
   - Enter job description
   - Send OTP → Verify → Continue to ID Upload
   ↓
7. ID Upload
   ↓
8. Selfie Verification
   ↓
9. Credentials & Achievements
   ↓
10. Final review & submit
```

---

## Summary Statistics

- **Files Created**: 13
- **Files Modified**: 15+
- **Major Features**: 6
- **Bug Fixes**: 10+
- **New Routes**: 2 (emailVerificationScreen, menteeOnboardingPage)
- **New Models**: 2 (MenteeProfileModel, UserDetailModel enhanced)
- **New Services**: 1 (CustomFirebaseOtpService)
- **Cloud Functions**: 3 (requestEmailOTP, verifyEmailOTP, resendEmailOTP)
