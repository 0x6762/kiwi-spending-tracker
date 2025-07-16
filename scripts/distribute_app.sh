#!/bin/bash

# Firebase App Distribution Script for Kiwi Spending Tracker
# This script builds and distributes the Android app to Firebase App Distribution

echo "🏗️  Building Android App Bundle..."

# Clean previous builds
flutter clean
flutter pub get

# Build the Android APK
flutter build apk --release --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Check if Firebase CLI is installed
    if command -v firebase &> /dev/null; then
        echo "🚀 Distributing to Firebase App Distribution..."
        
        # Distribute to Firebase
        firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
            --app "1:189891241708:android:b675086c9a5497706427c9" \
            --groups "beta-testers" \
            --release-notes "New build: $(date '+%Y-%m-%d %H:%M:%S')"
    else
        echo "⚠️  Firebase CLI not found. Please install it first:"
        echo "   npm install -g firebase-tools"
        echo "   firebase login"
        echo ""
        echo "📦 APK built successfully at:"
        echo "   build/app/outputs/flutter-apk/app-release.apk"
        echo ""
        echo "🌐 You can manually upload this to Firebase Console:"
        echo "   https://console.firebase.google.com/project/kiwi-b0ed0/appdistribution"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi 