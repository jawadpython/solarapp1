# Auth email API (Resend without Firebase Blaze)

When Firebase **Blaze billing is disabled**, Cloud Functions stop working. The app then falls back to Firebase’s default verification emails (`noreply@…firebaseapp.com`), which often land in **spam**.

This small server does the same job as `sendAuthVerificationEmail` / `sendAuthPasswordResetEmail` Cloud Functions, but runs on **Render** (free tier) — no Blaze plan needed.

## 1. Deploy on Render (free)

1. Push this repo to GitHub (if not already).
2. Go to [render.com](https://render.com) → **New** → **Web Service**.
3. Connect your repo.
4. Settings:
   - **Root directory:** `server/auth-email-api`
   - **Build command:** `npm install`
   - **Start command:** `npm start`
   - **Instance type:** Free
5. **Environment variables** (same values as `functions/.env`):

| Key | Value |
|-----|--------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full JSON from Firebase Console → Project settings → Service accounts → **Generate new private key** (paste as one line) |
| `RESEND_API_KEY` | Your `re_…` key |
| `RESEND_FROM_EMAIL` | e.g. `noreply@jawadsoftware.com` (domain must be verified in Resend) |
| `RESEND_FROM_NAME` | `Tawfir Energy` |
| `RESEND_REPLY_TO` | `support@jawadsoftware.com` (recommended — better than noreply-only) |

6. Deploy. Copy the public URL, e.g. `https://solarapp1.onrender.com`.

7. Test: open `https://YOUR-URL.onrender.com/health` — should return `{"ok":true}`.

## 2. Configure the Flutter app

Open `lib/core/constants/auth_email_api_config.dart`:

```dart
static const String fileBaseUrl = 'https://solarapp1.onrender.com';
```

Rebuild and publish the app.

## 3. Resend domain (still required)

In [Resend → Domains](https://resend.com/domains), `jawadsoftware.com` (or your sending domain) must show **Verified** with SPF + DKIM DNS records set.

Optional: add DMARC TXT at `_dmarc.jawadsoftware.com`:
```
v=DMARC1; p=none; rua=mailto:noreply@jawadsoftware.com
```

## 4. How the app chooses a sender

1. **Auth email API** (Render) — if `fileBaseUrl` is set (**no Firebase spam fallback**)
2. **Cloud Functions + Resend** — only if Blaze billing is enabled
3. **Firebase default** — only when API URL is **not** configured

## 5. Still landing in spam?

### Check which sender was used

Open the spam email → **Show original**:

| From | Meaning |
|------|---------|
| `noreply@jawadsoftware.com` | Resend worked — fix DNS/reputation below |
| `@firebaseapp.com` | Old app or API failed — rebuild APK + check Render logs |

Also check [Resend → Emails](https://resend.com/emails) after a test — if empty, Render did not send.

### Resend dashboard (do now)

1. Domain **Verified** (SPF + DKIM green)
2. **Disable Open tracking** and **Click tracking** on that domain
3. Add **DMARC** (see section 3)
4. Redeploy Render after pulling latest `server/auth-email-api` code

### Rebuild the app

```powershell
flutter build apk --release
```

The latest app retries Render cold starts (up to 90s) and will **not** silently send Firebase spam emails.

### Domain mismatch (advanced)

Links in the email point to `firebaseapp.com` while From is `jawadsoftware.com` — filters dislike this. Long-term: connect your domain to Firebase Hosting and set `FIREBASE_AUTH_LINK_DOMAIN=jawadsoftware.com` on Render.

### New domain reputation

First emails may still hit spam. Mark **Not spam** once in Gmail — reputation improves quickly.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Email still from `@firebaseapp.com` | API URL not set in app, or API call failed — check Render logs |
| Render 500 on **Resend** button | See below — usually rate limit or bad env var |
| Health shows no `"version":2` | Old server still running — **Manual Deploy** on Render |

### Error 500 when tapping Resend (renvoyer)

1. **Redeploy Render** with latest `server/auth-email-api` code (health must show `"version":2`).
2. On Render → **Environment**, **remove** `FIREBASE_AUTH_LINK_DOMAIN` unless you connected that domain in Firebase Auth.
3. If the app says **"Too many verification emails"** — wait 15–30 minutes (Firebase rate limit).
4. If it says **"Session expired"** — sign out, sign in again, then resend.
5. Check Render **Logs** tab right after resend — the real error is logged there.

### Resend shows email but still spam

Resend **delivered** ≠ inbox. Gmail often puts new domains in spam until reputation builds:

1. Resend → your domain → **disable** Open + Click tracking
2. Add **DMARC** DNS record (section 3)
3. Change `RESEND_FROM_EMAIL` to `support@jawadsoftware.com` (not noreply)
4. Mark the email **Not spam** once in Gmail
5. Test score at [mail-tester.com](https://www.mail-tester.com) — send a verification to their address

The verification link uses `firebaseapp.com` while From is `jawadsoftware.com` — this hurts deliverability until you connect your own domain to Firebase Hosting.
| First email slow (~30s) | Free Render instance was asleep; normal on free tier |
| Cloud Function logs say “billing is disabled” | Expected on Spark — use this API instead |

## Local test

```bash
cd server/auth-email-api
cp .env.example .env
# fill .env
npm install
npm start
```

Then set `fileBaseUrl = 'http://localhost:8080'` for a debug build only.
