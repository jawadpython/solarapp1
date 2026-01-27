# Deploy Admin Dashboard V2 to Firebase Hosting

## Steps to Deploy the New Admin Dashboard

### 1. Build the Admin V2 for Web

Run this command from the project root:

```bash
flutter build web -t lib/main_admin_v2.dart --release
```

This will:
- Build the new admin dashboard (admin_v2)
- Output files to `build/web/`
- Use the entry point `lib/main_admin_v2.dart`

### 2. Deploy to Firebase Hosting

Make sure you're logged in to Firebase:

```bash
firebase login
```

Then deploy:

```bash
firebase deploy --only hosting
```

### 3. Verify Deployment

After deployment, visit your Firebase hosting URL to see the new admin dashboard.

---

## Important Notes

- The old admin dashboard in `admin_dashboard/` folder is no longer used
- The new admin dashboard is in `lib/admin_v2/` and uses `lib/main_admin_v2.dart` as entry point
- The `firebase.json` at the root now points to `build/web` which will contain the new admin build
- Make sure to build with `-t lib/main_admin_v2.dart` to use the correct entry point

---

## Quick Deploy Script

You can create a batch file (`deploy_admin_v2.bat`) or PowerShell script (`deploy_admin_v2.ps1`):

**deploy_admin_v2.bat:**
```batch
@echo off
echo Building Admin V2 for web...
flutter build web -t lib/main_admin_v2.dart --release
echo.
echo Deploying to Firebase Hosting...
firebase deploy --only hosting
echo.
echo Done!
pause
```

**deploy_admin_v2.ps1:**
```powershell
Write-Host "Building Admin V2 for web..." -ForegroundColor Green
flutter build web -t lib/main_admin_v2.dart --release
Write-Host ""
Write-Host "Deploying to Firebase Hosting..." -ForegroundColor Green
firebase deploy --only hosting
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
```

---

## Troubleshooting

If you see the old admin dashboard:
1. Make sure you built with `-t lib/main_admin_v2.dart`
2. Clear the build folder: `flutter clean`
3. Rebuild: `flutter build web -t lib/main_admin_v2.dart --release`
4. Redeploy: `firebase deploy --only hosting`

If you see errors:
- Check that all dependencies are installed: `flutter pub get`
- Check that Firebase is properly configured
- Check browser console for errors
