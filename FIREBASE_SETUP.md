# Firebase Setup Guide for DigiUni Portal

This guide will help you set up Firebase for your Flutter school portal application.

## Prerequisites

- Flutter SDK installed
- Firebase account
- Android Studio / Xcode (for platform-specific setup)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "digiuni-portal")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 3: Enable Firestore Database

1. In your Firebase project, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 4: Set Up Security Rules

1. In Firestore Database, go to "Rules" tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read their own data, admins can read all
    match /users/{userId} {
      allow read: if request.auth != null && (request.auth.uid == userId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Students collection - students can read/write their own data, teachers can read assigned students, admins can read all
    match /students/{studentId} {
      allow read: if request.auth != null && (
        request.auth.uid == studentId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['teacher', 'admin']
      );
      allow write: if request.auth != null && (
        request.auth.uid == studentId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      
      // Student subcollections
      match /{subcollection}/{document=**} {
        allow read, write: if request.auth != null && (
          request.auth.uid == studentId || 
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['teacher', 'admin']
        );
      }
    }
    
    // Teachers collection - teachers can read/write their own data, admins can read all
    match /teachers/{teacherId} {
      allow read: if request.auth != null && (
        request.auth.uid == teacherId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      allow write: if request.auth != null && (
        request.auth.uid == teacherId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
    }
    
    // Classes collection - teachers can read/write their assigned classes, admins can read all
    match /classes/{classId} {
      allow read: if request.auth != null && (
        resource.data.assignedTeacher == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      allow write: if request.auth != null && (
        resource.data.assignedTeacher == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
    }
    
    // Timetables collection - teachers can read/write their class timetables, admins can read all
    match /timetables/{timetableId} {
      allow read: if request.auth != null && (
        resource.data.assignedTeacher == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      allow write: if request.auth != null && (
        resource.data.assignedTeacher == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
    }
    
    // Events collection - authenticated users can read, teachers and admins can write
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['teacher', 'admin']
      );
    }
    
    // Notifications collection - users can read their notifications, teachers and admins can write
    match /notifications/{notificationId} {
      allow read: if request.auth != null && (
        resource.data.targetUserId == request.auth.uid || 
        resource.data.targetUserId == null
      );
      allow write: if request.auth != null && (
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['teacher', 'admin']
      );
    }
  }
}
```

## Step 5: Configure Android App

1. In Firebase project, click the Android icon (</>) to add an Android app
2. Enter your package name: `com.example.digiuni_portal`
3. Enter app nickname: "DigiUni Portal"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/` directory
7. Click "Next" and follow the setup instructions

## Step 6: Configure iOS App

1. In Firebase project, click the iOS icon to add an iOS app
2. Enter your bundle ID: `com.example.digiuniPortal`
3. Enter app nickname: "DigiUni Portal"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/` directory
7. Click "Next" and follow the setup instructions

## Step 7: Configure Web App

1. In Firebase project, click the web icon to add a web app
2. Enter app nickname: "DigiUni Portal Web"
3. Click "Register app"
4. Copy the Firebase configuration object
5. Update the configuration in `web/index.html` with your actual values

## Step 8: Update Configuration Files

Replace the placeholder values in the following files with your actual Firebase project values:

### `lib/firebase_options.dart`
- Replace `YOUR_API_KEY` with your actual API key
- Replace `YOUR_APP_ID` with your actual app ID
- Replace `YOUR_MESSAGING_SENDER_ID` with your actual messaging sender ID
- Replace `YOUR_PROJECT_ID` with your actual project ID

### `android/app/google-services.json`
- Replace all placeholder values with actual values from your Firebase project

### `ios/Runner/GoogleService-Info.plist`
- Replace all placeholder values with actual values from your Firebase project

### `web/index.html`
- Replace all placeholder values in the Firebase configuration object

## Step 9: Install Dependencies

Run the following command to install all required dependencies:

```bash
flutter pub get
```

## Step 10: Create Initial Data Structure

After setting up Firebase, you'll need to create the initial data structure. You can do this manually through the Firebase Console or programmatically.

### Required Collections:

1. **users** - User accounts and roles
2. **students** - Student profiles and data
3. **teachers** - Teacher profiles and data
4. **classes** - Class information and assignments
5. **timetables** - Class schedules
6. **events** - School events and announcements
7. **notifications** - User notifications

### Sample User Document Structure:

```json
{
  "email": "student@example.com",
  "name": "John Doe",
  "role": "student",
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLoginAt": "2024-01-01T00:00:00Z",
  "isActive": true
}
```

## Step 11: Create Admin Account

1. Use Firebase Authentication to create the first admin user
2. Manually set the role to "admin" in the Firestore users collection
3. Use this admin account to create other users through the app

## Step 12: Test the Integration

1. Run the app: `flutter run`
2. Try logging in with test credentials
3. Verify that data is being read/written to Firestore
4. Check Firebase Console for authentication and database activity

## Troubleshooting

### Common Issues:

1. **"Target of URI doesn't exist" errors**: Make sure you've run `flutter pub get`
2. **Firebase initialization errors**: Verify your configuration files are correct
3. **Permission denied errors**: Check your Firestore security rules
4. **Authentication errors**: Ensure Email/Password authentication is enabled

### Debug Steps:

1. Check Firebase Console for error logs
2. Verify configuration values match your project
3. Ensure all required dependencies are installed
4. Check platform-specific setup (Android/iOS)

## Security Notes

- The provided security rules are for development/testing
- For production, implement more restrictive rules
- Consider implementing Firebase Custom Claims for role-based access
- Regularly review and update security rules

## Support

If you encounter issues:
1. Check Firebase documentation
2. Review Flutter Firebase plugin documentation
3. Check Firebase Console for error logs
4. Verify your configuration matches the examples

## Next Steps

After successful setup:
1. Customize the data models as needed
2. Implement additional security rules
3. Add Firebase Analytics (optional)
4. Set up Firebase Cloud Functions for complex operations
5. Configure Firebase Hosting for web deployment
