# 🏗️ Build Guide

Quick guide for building the Kiwi Spending Tracker app.

## 🚀 Quick Build Commands

### Debug Build (for testing)
```bash
# For quick testing without Firebase
flutter run --debug
# Or install directly to connected device
flutter install
```

### Release Build + Distribution
```bash
# Windows
.\scripts\distribute_app.ps1

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
| **Debug build fails** | Use `flutter run` instead of `flutter build apk --debug` |

## 📱 App Installation

- **APK location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Install on device**: `flutter install` or transfer APK manually

---

**That's it! Keep it simple.** 🎯 