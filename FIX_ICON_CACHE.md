# 🔧 Fix iOS App Icon Not Showing on Simulator

If you've replaced app icons but they're not showing on the simulator, follow these steps:

## Step 1: Clean Build Folders

```bash
cd "/Users/pc/Desktop/solarapp1 copy"
flutter clean
```

## Step 2: Delete App from Simulator

1. **On Simulator:** Find your app icon (Tawfir Energy)
2. **Long press** on the app icon
3. **Tap "Remove App"** or delete it
4. Confirm deletion

Alternatively, you can reset the simulator:
- **Simulator Menu** → **Device** → **Erase All Content and Settings...**

## Step 3: Clean Xcode Derived Data

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

## Step 4: Restart Simulator

1. **Quit Simulator** completely
2. Reopen Simulator
3. Select your device (e.g., iPhone 14 Pro Max)

## Step 5: Rebuild and Run

```bash
cd "/Users/pc/Desktop/solarapp1 copy"
flutter run
```

## Alternative: Use Xcode to Verify Icons

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **General** tab
4. Check **App Icons and Launch Images**
5. Verify all icon slots show your new images
6. If some are missing, click on them and select your new icon files

## Important Notes:

✅ **Contents.json** has been created - This file tells iOS which image files to use for each icon size.

✅ **All icon files** should be present:
- iPhone: 20x20@2x, 20x20@3x, 29x29@1x-3x, 40x40@2x-3x, 60x60@2x-3x
- iPad: 20x20@1x-2x, 29x29@1x-2x, 40x40@1x-2x, 76x76@1x-2x, 83.5x83.5@2x
- App Store: 1024x1024@1x

⚠️ **Icon Size Requirements:**
- All icons must be PNG format
- Sizes must match exactly (e.g., 60x60@3x = 180x180 pixels)
- 1024x1024 icon cannot have transparency

## Still Not Working?

If icons still don't update:

1. **Check icon dimensions** - Open each PNG and verify actual pixel dimensions match:
   - `Icon-App-60x60@3x.png` should be 180×180 pixels
   - `Icon-App-1024x1024@1x.png` should be 1024×1024 pixels

2. **Verify Contents.json** - Make sure filenames in Contents.json match actual file names exactly

3. **Check Xcode Asset Catalog** - Open in Xcode and verify all slots are filled

4. **Restart Xcode** if it's open

5. **Hard reset simulator:**
   ```bash
   xcrun simctl shutdown all
   xcrun simctl erase all
   ```
