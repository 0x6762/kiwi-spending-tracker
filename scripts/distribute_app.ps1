# Simple Firebase Distribution Script
# Builds and distributes the Android app

Write-Host "Building release APK..." -ForegroundColor Green

flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Try to distribute via Firebase CLI
    if (Get-Command firebase -ErrorAction SilentlyContinue) {
        # Get App ID from firebase_options.dart
        $appId = (Get-Content lib/firebase_options.dart | Select-String "appId: '([^']+)'" | ForEach-Object { $_.Matches.Groups[1].Value })
        
        if ($appId) {
            Write-Host "Distributing via Firebase..." -ForegroundColor Blue
            firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app "$appId" --groups "beta-testers"
        } else {
            Write-Host "Could not find App ID in firebase_options.dart" -ForegroundColor Red
        }
    } else {
        Write-Host "Firebase CLI not found. Install with: npm install -g firebase-tools" -ForegroundColor Yellow
    }
    
    Write-Host "APK ready: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
} else {
    Write-Host "Build failed!" -ForegroundColor Red
} 