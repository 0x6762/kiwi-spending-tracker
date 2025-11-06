#!/bin/bash

# Build Script for Google Play Console
# Builds the Android app for distribution

# Check if --appbundle flag is provided
BUILD_APPBUNDLE=false
if [ "$1" == "--appbundle" ] || [ "$1" == "-a" ]; then
    BUILD_APPBUNDLE=true
fi

echo "🏗️ Building release build..."

flutter clean
flutter pub get

if [ "$BUILD_APPBUNDLE" = true ]; then
    echo "📦 Building App Bundle for Google Play Store..."
    flutter build appbundle --release --no-tree-shake-icons
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful!"
        echo "📦 App Bundle ready: build/app/outputs/bundle/release/app-release.aab"
        echo "📤 Upload to Google Play Console → Testing → Closed testing"
    else
        echo "❌ Build failed!"
        exit 1
    fi
else
    echo "📱 Building APK..."
    flutter build apk --release --no-tree-shake-icons
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful!"
        echo "📱 APK ready: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "❌ Build failed!"
        exit 1
    fi
fi 