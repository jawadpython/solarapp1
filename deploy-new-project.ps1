# Deploy to NEW Firebase project (solar-app-f698e)
# Run this from the project root: .\deploy-new-project.ps1

Write-Host "Setting active project to solar-app-f698e..." -ForegroundColor Cyan
firebase use solar-app-f698e

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to switch project. Make sure you're logged in with the account that owns solar-app-f698e:" -ForegroundColor Red
    Write-Host "  firebase login" -ForegroundColor Yellow
    Write-Host "  firebase use solar-app-f698e" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nDeploying Storage..." -ForegroundColor Cyan
firebase deploy --only storage
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "`nDeploying Firestore..." -ForegroundColor Cyan
firebase deploy --only firestore
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "`nDeploying Functions..." -ForegroundColor Cyan
firebase deploy --only functions
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "`nDone. All deployed to solar-app-f698e" -ForegroundColor Green
