# Build Script for Google Play Console
# Builds the Android app for distribution

param(
    [switch]$AppBundle = $false
)

Write-Host "Building release build..." -ForegroundColor Green

flutter clean
flutter pub get

if ($AppBundle) {
    Write-Host "Building App Bundle for Google Play Store..." -ForegroundColor Cyan
    flutter build appbundle --release --no-tree-shake-icons
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful!" -ForegroundColor Green
        Write-Host "📦 App Bundle ready: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Green
        Write-Host "📤 Upload to Google Play Console → Testing → Closed testing" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
    }
} else {
    Write-Host "Building APK..." -ForegroundColor Cyan
    flutter build apk --release --no-tree-shake-icons
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful!" -ForegroundColor Green
        Write-Host "📱 APK ready: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
    }
} 