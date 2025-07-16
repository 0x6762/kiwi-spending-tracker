# Firebase App Distribution Setup Guide

This guide will help you set up Firebase App Distribution for your Kiwi Spending Tracker app.

## 🚀 Quick Start Checklist

- [ ] Create Firebase project
- [ ] Add Android app to Firebase
- [ ] Download and place `google-services.json`
- [ ] Update Firebase configuration
- [ ] Install Firebase CLI
- [ ] Build and distribute app

## 📋 Detailed Steps

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Project name: `kiwi-spending-tracker`
4. **Skip Google Analytics** (can be added later)
5. Click "Create Project"

### Step 2: Add Android App

1. In your Firebase project, click the Android icon
2. **Android package name**: `com.kiwi.spending_tracker`
3. **App nickname**: `Kiwi Spending Tracker`
4. **Skip** Debug signing certificate SHA-1 (not needed for distribution)
5. Click "Register app"

### Step 3: Download Configuration File

1. Download `google-services.json`
2. Place it in your project at: `android/app/google-services.json`

### Step 4: Update Firebase Configuration

You need to update `lib/firebase_options.dart` with your actual Firebase project details:

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the configuration values and update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',           // From Firebase Console
  appId: 'YOUR_APP_ID_HERE',             // From Firebase Console  
  messagingSenderId: 'YOUR_SENDER_ID_HERE', // From Firebase Console
  projectId: 'kiwi-spending-tracker',     // Your project ID
  storageBucket: 'kiwi-spending-tracker.appspot.com',
);
```

### Step 5: Install Firebase CLI

**Option A: Using npm (if Node.js is installed)**
```bash
npm install -g firebase-tools
firebase login
```

**Option B: Download standalone binary**
1. Go to [Firebase CLI Releases](https://github.com/firebase/firebase-tools/releases)
2. Download `firebase-tools-win.exe`
3. Rename to `firebase.exe`
4. Add to your PATH

### Step 6: Enable App Distribution

1. In Firebase Console, go to **App Distribution**
2. Click "Get started"
3. Add testers by email address
4. Create a group called "beta-testers"

### Step 7: Build and Test

Run the dependencies update:
```bash
flutter pub get
```

Test the build:
```bash
flutter build apk --release --no-tree-shake-icons
```

The APK will be created at: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Distribution Options

### Option A: Using Scripts (Recommended)

**For Windows PowerShell:**
```powershell
.\scripts\distribute_app.ps1
```

**For Bash/Linux/Mac:**
```bash
chmod +x scripts/distribute_app.sh
./scripts/distribute_app.sh
```

### Option B: Manual Firebase CLI

1. Update the script with your Firebase App ID
2. Run the distribution command:

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "1:189891241708:android:b675086c9a5497706427c9" \
  --groups "beta-testers" \
  --release-notes "Beta release v0.1.0"
```

### Option C: Firebase Console Upload

1. Go to Firebase Console → App Distribution
2. Click "Distribute"
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Add testers and release notes
5. Click "Distribute"

## 🔧 Configuration Values You Need

From your Firebase Console, you'll need these values:

| Value | Where to Find |
|-------|---------------|
| **API Key** | Project Settings → General → Your apps |
| **App ID** | Project Settings → General → Your apps |
| **Sender ID** | Project Settings → Cloud Messaging |
| **Project ID** | Project Settings → General (top of page) |
| **Firebase App ID** | App Distribution → App settings |

## 📱 Testing the Distribution

1. **Build the app**: `flutter build apk --release --no-tree-shake-icons`
2. **Distribute**: Use one of the options above
3. **Notify testers**: They'll receive an email with download link
4. **Collect feedback**: Use Firebase Console to monitor downloads

## 🔍 Troubleshooting

### Build Issues
- **Error: "google-services.json not found"**
  - Make sure the file is in `android/app/google-services.json`
  - Restart your IDE/terminal

### Distribution Issues
- **Error: "Firebase CLI not found"**
  - Install Firebase CLI using one of the methods above
  - Make sure it's in your PATH

- **Error: "App ID not found"**
  - Your Firebase App ID is: `1:189891241708:android:b675086c9a5497706427c9`
  - Find the ID in Firebase Console → App Distribution

### App Installation Issues
- **Error: "App not installed"**
  - Make sure testers enable "Install unknown apps" on Android
  - Use App Bundle (.aab) format, not APK

## 📈 Next Steps

Once distribution is working:
1. Set up automated builds with GitHub Actions
2. Add Firebase Analytics for user insights
3. Implement crash reporting with Firebase Crashlytics
4. Set up remote configuration for feature flags

## 🆘 Need Help?

If you encounter issues:
1. Check the [Firebase Console](https://console.firebase.google.com/)
2. Review the [Firebase documentation](https://firebase.google.com/docs/app-distribution)
3. Check the terminal output for specific error messages 