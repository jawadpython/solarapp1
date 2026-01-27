# PowerShell script to build and deploy Admin V2 to Firebase Hosting

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Admin Dashboard V2 Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous build
Write-Host "Step 1: Cleaning previous build..." -ForegroundColor Yellow
flutter clean
Write-Host ""

# Step 2: Get dependencies
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Step 3: Build for web with Admin V2 entry point
Write-Host "Step 3: Building Admin V2 for web..." -ForegroundColor Yellow
flutter build web -t lib/main_admin_v2.dart --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Build failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy to Firebase Hosting
Write-Host "Step 4: Deploying to Firebase Hosting..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Deployment failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your new Admin Dashboard V2 is now live!" -ForegroundColor Green
Write-Host ""
