# 🏗️ Build Guide

Quick guide for building the Kiwi Spending Tracker app.

## 🚀 Quick Build Commands

### Debug Build (for testing)
```bash
# Run on connected device/emulator
flutter run
```

### Release Build + Distribution
```bash
# Windows - Default (beta-testers)
.\scripts\distribute_app.ps1

# Windows - Alpha testers
.\scripts\distribute_app.ps1 -GroupName "alpha-testers"

# Windows - Beta testers (explicit)
.\scripts\distribute_app.ps1 -GroupName "beta-testers"

# Windows - With release notes
.\scripts\distribute_app.ps1 -GroupName "alpha-testers" -ReleaseNotes "New features: Recent Transactions section, 6-month chart view"

# Mac/Linux
./scripts/distribute_app.sh
```

## 📋 First-Time Setup

### 1. Firebase Configuration
Create your Firebase config files from templates:
```bash
# Copy templates
cp lib/firebase_options.dart.template lib/firebase_options.dart
cp android/app/google-services.json.template android/app/google-services.json
cp .firebaserc.template .firebaserc
```

### 2. Update Configuration
Replace placeholder values in the copied files with your actual Firebase project details.

### 3. Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

## 🔧 Manual Build Commands

### For Release (Firebase Distribution)
```bash
flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

## 📱 Distribution Groups

### Available Groups
- **alpha-testers**: Early access group for internal testing
- **beta-testers**: Public beta testing group (default)

### Script Parameters
- `-GroupName`: Target distribution group (default: "beta-testers")
- `-ReleaseNotes`: Optional release notes for the build

### For Debug Testing
```bash
flutter build apk --debug
```

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Build fails** | Run `flutter doctor` |
| **Firebase CLI not found** | Install with `npm install -g firebase-tools` |
| **Config file missing** | Copy from `.template` files |
| **Permission denied** | Run `firebase login` |
| **Debug build fails** | Check that Firebase config matches package name |

## 📱 App Installation

- **APK location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Install on device**: `flutter install` or transfer APK manually

---

**That's it! Keep it simple.** 🎯 