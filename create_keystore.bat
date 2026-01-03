@echo off
echo ========================================
echo   Create Release Keystore for Google Play
echo ========================================
echo.

cd android

echo This will create a keystore file for signing your app.
echo.
echo IMPORTANT: Remember your passwords! You'll need them to update your app.
echo.

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to create keystore.
    echo Make sure Java is installed and keytool is in your PATH.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Keystore created successfully!
echo ========================================
echo.
echo Next, you need to create key.properties file.
echo Please note down:
echo - Your keystore password
echo - Your key password (if different)
echo.
echo Press any key to continue...
pause >nul

cd ..

echo.
echo ========================================
echo   Creating key.properties template
echo ========================================
echo.

if exist android\key.properties (
    echo key.properties already exists. Backing up to key.properties.backup
    copy android\key.properties android\key.properties.backup >nul
)

(
echo storePassword=YOUR_KEYSTORE_PASSWORD_HERE
echo keyPassword=YOUR_KEY_PASSWORD_HERE
echo keyAlias=upload
echo storeFile=upload-keystore.jks
) > android\key.properties

echo.
echo ========================================
echo   IMPORTANT: Edit android\key.properties
echo ========================================
echo.
echo 1. Open: android\key.properties
echo 2. Replace YOUR_KEYSTORE_PASSWORD_HERE with your actual keystore password
echo 3. Replace YOUR_KEY_PASSWORD_HERE with your key password (or same as keystore)
echo 4. Save the file
echo.
echo After editing, run: flutter build appbundle --release
echo.
pause

