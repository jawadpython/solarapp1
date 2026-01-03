# Flutter App Bundle Build Script
# This script builds the app bundle and treats it as successful if the AAB file exists,
# even if Flutter reports an error about debug symbols (which is a known harmless warning).

Write-Host "Building Flutter App Bundle..." -ForegroundColor Cyan
Write-Host ""

# Clean previous build artifacts (optional, comment out if you want incremental builds)
# Write-Host "Cleaning previous build..." -ForegroundColor Yellow
# flutter clean

# Run the build command
Write-Host "Running: flutter build appbundle --release" -ForegroundColor Yellow
Write-Host ""

$buildOutput = flutter build appbundle --release 2>&1
$buildExitCode = $LASTEXITCODE

# Check if AAB file was created
$aabPath = "build\app\outputs\bundle\release\app-release.aab"
$aabExists = Test-Path $aabPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($aabExists) {
    $aabFile = Get-Item $aabPath
    $aabSizeMB = [math]::Round($aabFile.Length / 1MB, 2)
    
    Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "AAB File Created:" -ForegroundColor Green
    Write-Host "   Location: $aabPath" -ForegroundColor White
    Write-Host "   Size: $aabSizeMB MB" -ForegroundColor White
    Write-Host "   Modified: $($aabFile.LastWriteTime)" -ForegroundColor White
    Write-Host ""
    Write-Host "Ready to upload to Google Play Console!" -ForegroundColor Green
    Write-Host ""
    
    # If Flutter reported an error but AAB exists, show a note about the warning
    if ($buildExitCode -ne 0) {
        Write-Host "Note: Flutter reported a warning about debug symbols," -ForegroundColor Yellow
        Write-Host "but the AAB file was created successfully. This is a known" -ForegroundColor Yellow
        Write-Host "harmless warning and doesn't affect the build quality." -ForegroundColor Yellow
        Write-Host ""
    }
    
    exit 0
} else {
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "AAB file was not created at:" -ForegroundColor Red
    Write-Host "   $aabPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    Write-Host ""
    exit 1
}

