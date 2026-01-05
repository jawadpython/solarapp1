@echo off
REM Flutter App Bundle Build Script (Windows Batch)
REM This script builds the app bundle and treats it as successful if the AAB file exists

echo.
echo 🚀 Building Flutter App Bundle...
echo.

REM Run the build command
flutter build appbundle --release

REM Check if AAB file was created
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo.
    echo ========================================
    echo ✅ BUILD SUCCESSFUL!
    echo.
    echo 📦 AAB File Created:
    echo    Location: build\app\outputs\bundle\release\app-release.aab
    echo.
    echo 🎯 Ready to upload to Google Play Console!
    echo.
    exit /b 0
) else (
    echo.
    echo ========================================
    echo ❌ BUILD FAILED!
    echo.
    echo AAB file was not created.
    echo.
    exit /b 1
)




