# Firebase Hosting (build/web) must use the ADMIN entry point so
# https://<project>.firebaseapp.com shows the admin login, not the consumer app.
#
# Usage (from repo root):
#   .\scripts\build_firebase_hosting_admin.ps1
#   firebase deploy --only hosting

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Building Flutter web (admin dashboard) -> build/web ..."
flutter build web --release -t lib/main_admin_v2.dart
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Done. Deploy with: firebase deploy --only hosting"
