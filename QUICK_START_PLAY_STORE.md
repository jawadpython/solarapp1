# 🚀 Quick Start - Google Play Store Publishing

## ⚡ Quick Commands

### 1. Create Keystore (One-time setup)
```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure key.properties
```bash
cp android/key.properties.template android/key.properties
# Edit android/key.properties with your passwords
```

### 3. Build App Bundle
```bash
flutter build appbundle --release
```

### 4. Find Your AAB
```
build/app/outputs/bundle/release/app-release.aab
```

---

## ✅ Pre-Upload Checklist

- [ ] Keystore created and `key.properties` configured
- [ ] AAB built successfully
- [ ] App tested on physical device
- [ ] Privacy policy URL ready
- [ ] App icon 512×512 ready
- [ ] Feature graphic 1024×500 ready
- [ ] Screenshots ready (at least 2)
- [ ] Store listing text written

---

## 📋 Required Store Assets

| Asset | Size | Format | Required |
|-------|------|--------|----------|
| App Icon | 512×512 | PNG | ✅ Yes |
| Feature Graphic | 1024×500 | PNG | ✅ Yes |
| Phone Screenshots | 320-3840px | PNG/JPG | ✅ Yes (min 2) |
| Tablet Screenshots | Optional | PNG/JPG | ⚠️ Recommended |

---

## 🔗 Important Links

- **Play Console**: https://play.google.com/console
- **Full Guide**: See `GOOGLE_PLAY_SETUP_GUIDE.md`
- **Flutter Docs**: https://docs.flutter.dev/deployment/android

---

## ⚠️ Critical Reminders

1. **BACKUP YOUR KEYSTORE** - If lost, you cannot update your app!
2. **Version Code** must increase with each release (1, 2, 3...)
3. **Privacy Policy** is mandatory
4. **Data Safety Form** must be completed accurately

---

**Ready?** Follow the detailed guide in `GOOGLE_PLAY_SETUP_GUIDE.md` for step-by-step instructions.

