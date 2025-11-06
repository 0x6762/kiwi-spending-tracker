# 🏗️ Build Guide

Quick guide for building the Kiwi Spending Tracker app.

## 🚀 Quick Build Commands

### Debug Build (for testing)
```bash
# Run on connected device/emulator
flutter run
```

### Release Build for Google Play Console
```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release --no-tree-shake-icons

# Or build APK for direct distribution
flutter build apk --release --no-tree-shake-icons
```

## 📋 First-Time Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Signing (for release builds)
Create `android/key.properties` with your signing configuration:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

## 🔧 Manual Build Commands

### For Release
```bash
flutter clean
flutter pub get
flutter build appbundle --release --no-tree-shake-icons    # For Play Store
# OR
flutter build apk --release --no-tree-shake-icons          # For direct APK
```

### For Debug Testing
```bash
flutter build apk --debug
```

## 📱 Google Play Console Distribution

### Uploading to Closed Testing

1. **Build the App Bundle**:
   ```bash
   flutter build appbundle --release --no-tree-shake-icons
   ```

2. **Upload to Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Navigate to your app → Testing → Closed testing
   - Create a new release
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Add release notes and testers
   - Submit for review

### APK Location
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Build fails** | Run `flutter doctor` |
| **Signing errors** | Check `android/key.properties` configuration |
| **Debug build fails** | Run `flutter clean` and try again |

## 📱 App Installation

- **APK location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Install on device**: `flutter install` or transfer APK manually

---

**That's it! Keep it simple.** 🎯 