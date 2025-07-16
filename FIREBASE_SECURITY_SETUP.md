# Firebase Security Setup Guide

## 🔒 Security Best Practices

This guide outlines the security measures implemented in this project to protect sensitive Firebase configuration data.

## 🚨 Important Security Notice

**Never commit sensitive Firebase configuration files to version control!**

The following files contain sensitive API keys and configuration data:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `.firebaserc`

## 📋 Initial Setup for New Developers

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd kiwi-spending-tracker
```

### Step 2: Configure Firebase
1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)
2. **Add your Android app** to the Firebase project
3. **Download `google-services.json`** and place it in `android/app/`
4. **Generate Firebase configuration** using FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### Step 3: Set Up Configuration Files
1. **Copy the template file**:
   ```bash
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   ```
2. **Replace placeholder values** in `lib/firebase_options.dart` with your actual Firebase configuration
3. **Create `.firebaserc`** with your project ID:
   ```json
   {
     "projects": {
       "default": "your-project-id"
     }
   }
   ```

## 🔧 Firebase Security Rules

### Authentication Rules
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Expenses belong to authenticated users
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Rules
```javascript
// Storage Security Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🛡️ Additional Security Measures

### 1. API Key Restrictions
- **Restrict API keys** in Firebase Console → Project Settings → API Keys
- **Set application restrictions** to your app's package name
- **Enable only required APIs** (Firebase Authentication, Firestore, etc.)

### 2. Firebase App Check
Enable App Check for additional security:
```dart
// Add to your main.dart
await FirebaseAppCheck.instance.activate(
  webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  androidProvider: AndroidProvider.debug,
);
```

### 3. Environment-Specific Configuration
For different environments (dev, staging, prod):
```dart
// Create environment-specific configuration
class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kDebugMode) {
      return _developmentConfig;
    } else {
      return _productionConfig;
    }
  }
}
```

## 🔄 Continuous Integration Setup

### GitHub Actions Security
```yaml
# .github/workflows/build.yml
name: Build and Test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Firebase Configuration
        run: |
          echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > android/app/google-services.json
          echo '${{ secrets.FIREBASE_OPTIONS }}' > lib/firebase_options.dart
          echo '${{ secrets.FIREBASERC }}' > .firebaserc
```

## 📝 Security Checklist

- [ ] All Firebase configuration files are in `.gitignore`
- [ ] API keys are restricted in Firebase Console
- [ ] Firestore security rules are properly configured
- [ ] Storage security rules are implemented
- [ ] App Check is enabled for production
- [ ] Environment-specific configurations are set up
- [ ] CI/CD secrets are properly configured
- [ ] Regular security audits are performed

## 🚨 What to Do If Keys Are Exposed

If you accidentally commit sensitive keys:

1. **Regenerate API keys** immediately in Firebase Console
2. **Revoke the exposed keys**
3. **Remove keys from git history**:
   ```bash
   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch path/to/sensitive/file' --prune-empty --tag-name-filter cat -- --all
   ```
4. **Update all team members** with new configuration
5. **Review access logs** in Firebase Console

## 📞 Support

For questions about Firebase security setup, contact the development team or refer to:
- [Firebase Security Documentation](https://firebase.google.com/docs/security)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

**Remember: Security is everyone's responsibility!** 🔒 