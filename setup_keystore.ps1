# PowerShell Script: Complete Keystore Setup
# This script will guide you through creating the keystore and key.properties

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Release Signing Setup for Google Play" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "android")) {
    Write-Host "❌ Error: 'android' folder not found." -ForegroundColor Red
    Write-Host "Please run this script from the project root directory." -ForegroundColor Yellow
    exit 1
}

# Check if keystore already exists
$keystorePath = "android\upload-keystore.jks"
if (Test-Path $keystorePath) {
    Write-Host "⚠️  Keystore already exists: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to create a new one? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Using existing keystore..." -ForegroundColor Cyan
        $skipKeystore = $true
    } else {
        Write-Host "Removing old keystore..." -ForegroundColor Yellow
        Remove-Item $keystorePath -Force
        $skipKeystore = $false
    }
} else {
    $skipKeystore = $false
}

# Step 1: Create Keystore
if (-not $skipKeystore) {
    Write-Host ""
    Write-Host "STEP 1: Creating Keystore" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You will be prompted to enter:" -ForegroundColor Yellow
    Write-Host "  • Keystore password (REMEMBER THIS!)" -ForegroundColor White
    Write-Host "  • Your name/company information" -ForegroundColor White
    Write-Host "  • Country code (2 letters, e.g., MA, FR, DZ)" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Enter to continue..." -ForegroundColor Cyan
    Read-Host | Out-Null
    
    Set-Location android
    $keytoolResult = & keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload 2>&1
    Set-Location ..
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Keystore created successfully!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Failed to create keystore." -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible issues:" -ForegroundColor Yellow
        Write-Host "  • Java not installed or not in PATH" -ForegroundColor White
        Write-Host "  • Try: 'java -version' to check" -ForegroundColor White
        Write-Host ""
        Write-Host "Manual command:" -ForegroundColor Cyan
        Write-Host "  cd android" -ForegroundColor White
        Write-Host "  keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "✅ Using existing keystore" -ForegroundColor Green
}

# Step 2: Create key.properties
Write-Host ""
Write-Host "STEP 2: Creating key.properties" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

$keyPropertiesPath = "android\key.properties"

if (Test-Path $keyPropertiesPath) {
    Write-Host "⚠️  key.properties already exists." -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Keeping existing key.properties..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "✅ Setup complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Verify android\key.properties has correct passwords" -ForegroundColor White
        Write-Host "  2. Run: flutter clean" -ForegroundColor White
        Write-Host "  3. Run: flutter build appbundle --release" -ForegroundColor White
        exit 0
    }
}

Write-Host "Enter your keystore information:" -ForegroundColor Yellow
Write-Host ""

$storePassword = Read-Host "Enter keystore password" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

Write-Host ""
$useSamePassword = Read-Host "Use same password for key? (y/n, default: y)"
if ([string]::IsNullOrWhiteSpace($useSamePassword) -or $useSamePassword -eq "y" -or $useSamePassword -eq "Y") {
    $keyPassword = $storePasswordPlain
    Write-Host "Using same password for key." -ForegroundColor Cyan
} else {
    $keyPasswordSecure = Read-Host "Enter key password" -AsSecureString
    $keyPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPasswordSecure))
}

$keyAlias = Read-Host "Enter key alias (default: upload)"
if ([string]::IsNullOrWhiteSpace($keyAlias)) {
    $keyAlias = "upload"
}

$storeFile = "upload-keystore.jks"

# Write key.properties
$content = @"
storePassword=$storePasswordPlain
keyPassword=$keyPassword
keyAlias=$keyAlias
storeFile=$storeFile
"@

$content | Out-File -FilePath $keyPropertiesPath -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "✅ key.properties created successfully!" -ForegroundColor Green
Write-Host ""

# Verify files exist
Write-Host "Verifying setup..." -ForegroundColor Cyan
if (Test-Path "android\upload-keystore.jks") {
    Write-Host "  ✅ Keystore: android\upload-keystore.jks" -ForegroundColor Green
} else {
    Write-Host "  ❌ Keystore not found!" -ForegroundColor Red
}

if (Test-Path "android\key.properties") {
    Write-Host "  ✅ key.properties: android\key.properties" -ForegroundColor Green
} else {
    Write-Host "  ❌ key.properties not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Backup your keystore to a secure location!" -ForegroundColor Yellow
Write-Host "     Location: android\upload-keystore.jks" -ForegroundColor White
Write-Host "  2. Save your passwords in a password manager" -ForegroundColor Yellow
Write-Host "  3. Run: flutter clean" -ForegroundColor White
Write-Host "  4. Run: flutter build appbundle --release" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: If you lose the keystore, you CANNOT update your app!" -ForegroundColor Red
Write-Host ""

