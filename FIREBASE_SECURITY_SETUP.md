# 🔒 Firebase Security Setup

## Important Files to Keep Secret

These files contain sensitive API keys and should **never** be committed:
- `android/app/google-services.json`
- `lib/firebase_options.dart`
- `.firebaserc`

## Setup for New Developers

1. **Copy templates**:
   ```bash
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   cp android/app/google-services.json.template android/app/google-services.json
   cp .firebaserc.template .firebaserc
   ```

2. **Get your Firebase config** from [Firebase Console](https://console.firebase.google.com/)

3. **Replace placeholders** in the copied files with your actual values

## Security Best Practices

1. **Restrict API Key** in Firebase Console:
   - Go to Project Settings → API Keys
   - Set application restrictions to `com.kiwi.spending_tracker`

2. **Set Firestore Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Files are in `.gitignore`** - they won't be committed to the repository

## If Keys Are Exposed

1. **Regenerate API keys** in Firebase Console
2. **Update all team members** with new config
3. **Check Firebase Console** for any suspicious activity

---

**Keep it secure!** 🔒 