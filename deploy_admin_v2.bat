@echo off
echo ========================================
echo   Admin Dashboard V2 Deployment
echo ========================================
echo.

echo Step 1: Cleaning previous build...
flutter clean
echo.

echo Step 2: Getting dependencies...
flutter pub get
echo.

echo Step 3: Building Admin V2 for web...
flutter build web -t lib/main_admin_v2.dart --release

if errorlevel 1 (
    echo.
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo Build successful!
echo.

echo Step 4: Deploying to Firebase Hosting...
firebase deploy --only hosting

if errorlevel 1 (
    echo.
    echo Deployment failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Deployment Complete!
echo ========================================
echo.
echo Your new Admin Dashboard V2 is now live!
echo.
pause
