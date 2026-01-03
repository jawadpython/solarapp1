# 🔧 Build Troubleshooting Guide

## Common Build Errors & Solutions

### Error 1: "Signing config 'release' is missing required property"
**Solution**: The keystore file doesn't exist yet. This is OK for now - the build will use debug signing.

**Fix**: Either:
- Create keystore and `key.properties` (see guide)
- OR temporarily disable release signing (build will use debug)

### Error 2: "Could not find proguard-rules.pro"
**Solution**: The ProGuard rules file is missing.

**Fix**: The file should be at `android/app/proguard-rules.pro`. If missing, it was created in the setup.

### Error 3: "MultiDexApplication not found"
**Solution**: MultiDex dependency might be missing.

**Fix**: Already added in `build.gradle.kts`. Run:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
```

### Error 4: "Execution failed for task ':app:minifyReleaseWithR8'"
**Solution**: ProGuard/R8 is removing required code.

**Temporary Fix**: Disable minify temporarily:
```kotlin
isMinifyEnabled = false
isShrinkResources = false
```

### Error 5: "Gradle sync failed"
**Solution**: Gradle cache or dependency issues.

**Fix**:
```bash
flutter clean
cd android
./gradlew clean
./gradlew --stop
cd ..
flutter pub get
flutter build appbundle --release
```

### Error 6: "Namespace not found" or "Package not found"
**Solution**: Clean and rebuild.

**Fix**:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build appbundle --release
```

### Warning: "Release app bundle failed to strip debug symbols from native libraries"
**Status**: ⚠️ **HARMLESS WARNING** - Build is still successful!

**What it means**: Flutter couldn't strip debug symbols from native libraries, but this doesn't affect the AAB file.

**Solution**: 
- ✅ **The AAB file is created successfully** at `build/app/outputs/bundle/release/app-release.aab`
- ✅ **The AAB is valid for Google Play upload**
- ✅ **You can ignore this warning**

**Note**: This is a known Flutter issue and doesn't prevent your app from being published. The AAB file is production-ready despite the warning.

**Verify AAB exists**:
```bash
# Windows PowerShell
Test-Path build\app\outputs\bundle\release\app-release.aab

# Linux/Mac
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## Quick Fix: Disable Optimization Temporarily

If build fails with minify/shrink errors, temporarily disable them:

**Edit `android/app/build.gradle.kts`**:
```kotlin
release {
    signingConfig = if (keystorePropertiesFile.exists()) {
        signingConfigs.getByName("release")
    } else {
        signingConfigs.getByName("debug")
    }
    
    // TEMPORARILY DISABLED - Enable after fixing issues
    isMinifyEnabled = false
    isShrinkResources = false
}
```

Build, then re-enable and fix ProGuard rules.

---

## Step-by-Step Debug Process

1. **Get Full Error**:
   ```bash
   flutter build appbundle --release --verbose
   ```

2. **Check Gradle Logs**:
   ```bash
   cd android
   ./gradlew assembleRelease --stacktrace
   ```

3. **Clean Everything**:
   ```bash
   flutter clean
   cd android && ./gradlew clean && cd ..
   rm -rf build/
   flutter pub get
   ```

4. **Try Building Again**:
   ```bash
   flutter build appbundle --release
   ```

---

## Still Having Issues?

**Please provide**:
1. Full error message from terminal
2. Output of `flutter doctor -v`
3. Android SDK version
4. Gradle version

Then we can provide a targeted fix!

