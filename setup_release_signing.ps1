# PowerShell Script: Setup Release Signing for Google Play
# Run this script from the project root directory

Write-Host "🔐 Setting up Release Signing for Google Play" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "android")) {
    Write-Host "❌ Error: 'android' folder not found. Please run this script from the project root." -ForegroundColor Red
    exit 1
}

# Check if keystore already exists
$keystorePath = "android\upload-keystore.jks"
if (Test-Path $keystorePath) {
    Write-Host "⚠️  Keystore already exists at: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to create a new one? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Skipping keystore creation..." -ForegroundColor Yellow
    } else {
        Write-Host "Creating new keystore..." -ForegroundColor Cyan
        Remove-Item $keystorePath -Force
        & keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias upload
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Keystore created successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create keystore. Please run the keytool command manually." -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "Creating keystore..." -ForegroundColor Cyan
    Write-Host "You will be prompted to enter information. Remember your passwords!" -ForegroundColor Yellow
    Write-Host ""
    & keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Keystore created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create keystore." -ForegroundColor Red
        Write-Host "Make sure Java is installed and in your PATH." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# Check if key.properties already exists
$keyPropertiesPath = "android\key.properties"
if (Test-Path $keyPropertiesPath) {
    Write-Host "⚠️  key.properties already exists at: $keyPropertiesPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Keeping existing key.properties..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "✅ Setup complete! Your key.properties is already configured." -ForegroundColor Green
        exit 0
    }
}

# Create key.properties
Write-Host "Creating key.properties file..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Please enter your keystore information:" -ForegroundColor Yellow
Write-Host ""

$storePassword = Read-Host "Enter keystore password" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

$keyPasswordConfirm = Read-Host "Enter key password (or press Enter to use same as keystore password)"
if ([string]::IsNullOrWhiteSpace($keyPasswordConfirm)) {
    $keyPassword = $storePasswordPlain
    Write-Host "Using same password for key." -ForegroundColor Cyan
} else {
    $keyPassword = $keyPasswordConfirm
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
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Backup your keystore file: $keystorePath" -ForegroundColor White
Write-Host "2. Store your passwords in a secure location" -ForegroundColor White
Write-Host "3. Run: flutter clean" -ForegroundColor White
Write-Host "4. Run: flutter build appbundle --release" -ForegroundColor White
Write-Host ""
Write-Host "✅ Setup complete! Your app is ready for release signing." -ForegroundColor Green

