@echo off
echo ========================================
echo   CREATE RELEASE KEYSTORE - DO THIS NOW
echo ========================================
echo.
echo This will create the keystore file needed for Google Play.
echo.
echo IMPORTANT: You MUST remember the password you enter!
echo If you lose it, you CANNOT update your app on Google Play!
echo.
pause

cd android

echo.
echo Creating keystore...
echo You will be asked for:
echo   - Keystore password (REMEMBER IT!)
echo   - Your name/company
echo   - Country code (2 letters: MA, FR, DZ, etc.)
echo.
echo Press any key to start...
pause >nul

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to create keystore.
    echo.
    echo Make sure Java is installed.
    echo Try: java -version
    echo.
    pause
    exit /b 1
)

cd ..

echo.
echo ========================================
echo   Keystore created!
echo ========================================
echo.
echo Now you need to create key.properties file.
echo.
echo Please note down your keystore password.
echo.
pause

echo.
echo ========================================
echo   Creating key.properties
echo ========================================
echo.

set /p STORE_PASS="Enter your keystore password: "
set /p KEY_PASS="Enter key password (or press Enter to use same): "

if "%KEY_PASS%"=="" set KEY_PASS=%STORE_PASS%

(
echo storePassword=%STORE_PASS%
echo keyPassword=%KEY_PASS%
echo keyAlias=upload
echo storeFile=upload-keystore.jks
) > android\key.properties

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Files created:
echo   - android\upload-keystore.jks
echo   - android\key.properties
echo.
echo Next steps:
echo   1. BACKUP android\upload-keystore.jks to secure location
echo   2. Run: flutter clean
echo   3. Run: flutter build appbundle --release
echo.
echo Your AAB will now be signed for release!
echo.
pause

