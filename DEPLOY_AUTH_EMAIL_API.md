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

6. Deploy. Copy the public URL, e.g. `https://noor-auth-email.onrender.com`.

7. Test: open `https://YOUR-URL.onrender.com/health` — should return `{"ok":true}`.

## 2. Configure the Flutter app

Open `lib/core/constants/auth_email_api_config.dart`:

```dart
static const String fileBaseUrl = 'https://noor-auth-email.onrender.com';
```

Rebuild and publish the app.

## 3. Resend domain (still required)

In [Resend → Domains](https://resend.com/domains), `jawadsoftware.com` (or your sending domain) must show **Verified** with SPF + DKIM DNS records set.

Optional: add DMARC TXT at `_dmarc.jawadsoftware.com`:
```
v=DMARC1; p=none; rua=mailto:noreply@jawadsoftware.com
```

## 4. How the app chooses a sender

1. **Auth email API** (this server) — if `fileBaseUrl` is set  
2. **Cloud Functions + Resend** — only if Blaze billing is enabled  
3. **Firebase default** — spam-prone; used only when both above fail  

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Email still from `@firebaseapp.com` | API URL not set in app, or API call failed — check Render logs |
| Render 500 on send | Check Resend API key and verified domain |
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
