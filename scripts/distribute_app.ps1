# Firebase App Distribution Script for Kiwi Spending Tracker
# This script builds and distributes the Android app to Firebase App Distribution

Write-Host "Building Android App Bundle..." -ForegroundColor Green

# Clean previous builds
flutter clean
flutter pub get

# Build the Android APK
flutter build apk --release --no-tree-shake-icons

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Build successful!" -ForegroundColor Green
    
    # Check if Firebase CLI is installed
    if (Get-Command firebase -ErrorAction SilentlyContinue) {
        Write-Host "Distributing to Firebase App Distribution..." -ForegroundColor Blue
        
        # Distribute to Firebase
        firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk `
            --app "1:189891241708:android:b675086c9a5497706427c9" `
            --groups "beta-testers" `
            --release-notes "New build: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } else {
        Write-Host "WARNING: Firebase CLI not found. Please install it first:" -ForegroundColor Yellow
        Write-Host "   npm install -g firebase-tools" -ForegroundColor White
        Write-Host "   firebase login" -ForegroundColor White
        Write-Host ""
        Write-Host "APK built successfully at:" -ForegroundColor Green
        Write-Host "   build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
        Write-Host ""
        Write-Host "You can manually upload this to Firebase Console:" -ForegroundColor Blue
        Write-Host "   https://console.firebase.google.com/project/kiwi-b0ed0/appdistribution" -ForegroundColor White
    }
} else {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
} 