# Devis Request Firebase Troubleshooting Guide

## Issue: Devis requests not saving to Firebase

### What I've Added

1. **Enhanced Debugging** in `devis_service.dart`:
   - Logs Firebase initialization status
   - Logs each step of the save process
   - Detailed error messages with stack traces

2. **Enhanced Error Display** in `devis_request_screen.dart`:
   - Better error messages in UI
   - Console logging for debugging

## How to Test

1. **Open Browser Console** (F12 → Console tab)
2. **Submit a devis request** from the app
3. **Check the console logs** - you should see:
   - ✅ Firebase is initialized
   - 📝 Attempting to save devis request
   - 💾 Saving to Firestore collection
   - ✅ Successfully saved devis request

## Common Issues & Solutions

### Issue 1: Firebase Not Initialized
**Error:** `Firebase is not initialized`
**Solution:** 
- Check `lib/main.dart` has Firebase config
- Verify Firebase is initialized before app starts
- Check browser console for initialization errors

### Issue 2: Firestore Security Rules
**Error:** `PERMISSION_DENIED` or `Missing or insufficient permissions`
**Solution:** Update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to create devis requests
    match /devis_requests/{document=**} {
      allow create: if true;
      allow read: if request.auth != null; // Only authenticated users can read
      allow update, delete: if request.auth != null; // Only authenticated users can update/delete
    }
    
    // For testing, you can temporarily allow all operations:
    // match /{document=**} {
    //   allow read, write: if true;
    // }
  }
}
```

### Issue 3: Network/CORS Issues
**Error:** Network errors or CORS issues
**Solution:**
- Check internet connection
- Verify Firebase project is active
- Check browser network tab for failed requests

### Issue 4: Field Type Mismatch
**Error:** Field type errors
**Solution:**
- Ensure all numeric fields are numbers (not strings)
- Check `savingsMonth` and `savingsYear` are doubles
- Verify `panels` is an integer

## Testing Steps

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Open browser console** (F12)

3. **Navigate to calculator** → Calculate → Request Devis

4. **Fill the form** and submit

5. **Check console logs:**
   - Look for ✅ success messages
   - Look for ❌ error messages
   - Copy any error messages

6. **Check Firestore Console:**
   - Go to Firebase Console
   - Navigate to Firestore Database
   - Check if `devis_requests` collection exists
   - Check if new documents are being created

7. **Check Admin Dashboard:**
   - Run admin dashboard
   - Navigate to "Devis Requests" page
   - Check if requests appear (may need refresh)

## Debug Information to Share

If still not working, please share:

1. **Browser console logs** (copy all logs from console)
2. **Error message** shown in the app (if any)
3. **Firestore security rules** (current rules)
4. **Firebase project status** (is it active?)
5. **Network tab** (any failed requests?)

## Quick Fix: Test Firestore Rules

Temporarily set very permissive rules for testing:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **WARNING:** This allows anyone to read/write. Only use for testing!

## Expected Behavior

When working correctly:
1. User fills form and clicks "Envoyer la demande"
2. Loading indicator shows
3. Console shows success logs
4. Success dialog appears
5. Document appears in Firestore `devis_requests` collection
6. Document appears in Admin Dashboard

## Next Steps

1. Run the app and check console logs
2. Share the console output
3. Check Firestore security rules
4. Verify Firebase project is active

