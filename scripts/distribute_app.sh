#!/bin/bash

# Simple Firebase Distribution Script
# Builds and distributes the Android app

echo "🏗️ Building release APK..."

flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Try to distribute via Firebase CLI
    if command -v firebase &> /dev/null; then
        # Get App ID from firebase_options.dart
        APP_ID=$(grep -o "appId: '[^']*'" lib/firebase_options.dart | cut -d"'" -f2)
        
        if [ -n "$APP_ID" ]; then
            echo "🚀 Distributing via Firebase..."
            firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app "$APP_ID" --groups "beta-testers"
        else
            echo "❌ Could not find App ID in firebase_options.dart"
        fi
    else
        echo "⚠️ Firebase CLI not found. Install with: npm install -g firebase-tools"
    fi
    
    echo "📱 APK ready: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Build failed!"
fi 