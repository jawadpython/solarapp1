# Why Sign-Up & Forgot Password Emails Go to Spam (and How to Fix It)

## Emails in spam right now?

1. **Tell users to check spam/junk** – The app already says “check your email (including spam folder)”. Ask users to look in spam and, if they find the email, mark it as **Not spam** so future emails go to inbox.
2. **Send from your domain (best fix)** – Configure **Resend** below so verification and password-reset emails are sent from your domain (e.g. `noreply@yourdomain.com`) with SPF/DKIM. Then redeploy Cloud Functions.
3. **Firebase Console (quick win)** – In [Firebase Console](https://console.firebase.google.com) → your project (**solar-app-f698e**) → **Authentication** → **Templates**, set a clear **sender name** (e.g. “Tawfir Energy”) and edit the email templates. You can also set **SMTP** there if your provider supports it.

---

This project uses **Firebase Authentication** for:
- **Sign-up confirmation emails** (`sendEmailVerification()`)
- **Forgot password emails** (`sendPasswordResetEmail()`)

By default those emails are sent by Google/Firebase and often land in **spam**. This project includes a **custom email path** that sends from **your domain** via [Resend](https://resend.com) so deliverability improves.

---

## ✅ Implemented Fix: Send Auth Emails from Your Domain (Resend)

The app now **prefers** sending verification and password-reset emails through **Cloud Functions** using **Resend**. Emails are sent from your own address (e.g. `noreply@jawadsoftware.com`) with proper SPF/DKIM when you set that up with Resend, so they are much less likely to go to spam. If the Cloud Function is not configured or fails, the app falls back to Firebase’s built-in emails.

### Setup (required for the fix to work)

1. **Resend account and domain**
   - Sign up at [resend.com](https://resend.com).
   - Add and **verify your domain** (e.g. `jawadsoftware.com`) in the Resend dashboard. Resend will show the **SPF** and **DKIM** DNS records; add them at your domain registrar.
   - Create an **API key** (Resend dashboard → API Keys) and copy it (starts with `re_`).

2. **Environment variables for Cloud Functions**
   - In the project, go to the `functions` folder.
   - Copy `functions/.env.example` to `functions/.env`.
   - Edit `functions/.env` and set:
     - `RESEND_API_KEY=re_xxxxxxxx` (your Resend API key)
     - `RESEND_FROM_EMAIL=noreply@yourdomain.com` (use an address on the domain you verified in Resend)
     - `RESEND_FROM_NAME=Tawfir Energy` (optional; default is already “Tawfir Energy”)

3. **Firebase Blaze plan (required for Functions)**
   - Cloud Functions are **not** available on the free **Spark** plan. You must upgrade to **Blaze** (pay-as-you-go).
   - Upgrade here: [Firebase Console → Usage and billing → Modify plan](https://console.firebase.google.com/project/solar-app-f698e/usage/details)
   - Blaze has a **generous free tier**: 2M invocations/month free. For sign-up and password-reset emails only, you will almost certainly stay within the free tier and pay nothing. You only pay if you exceed the free quotas.

4. **Deploy Cloud Functions**
   - Install Node.js 18+ if needed.
   - From the **project root** (where `firebase.json` is), run:
     ```bash
     cd functions
     npm install
     cd ..
     firebase deploy --only functions
     ```
   - On first deploy, Firebase may prompt for the params; use the same values as in `.env`.

5. **Test**
   - Sign up with a new email or use “Forgot password” and check the inbox (and spam once) for the email from your domain.

After this, verification and password-reset emails are sent by your Cloud Functions via Resend from your domain. Keep the Firebase Console email templates as a fallback; the app only uses them when the callable fails (e.g. before you deploy or if Resend is misconfigured).

---

## Emails still landing in spam? Checklist

If you already use Resend and the Cloud Functions but messages still go to spam, work through this list.

### 1. Domain verified in Resend (mandatory)
- In [Resend → Domains](https://resend.com/domains), your sending domain (e.g. `jawadsoftware.com`) must be **Verified** (green check).
- If it shows “Pending” or “Unverified”, add the **exact** DNS records Resend shows (SPF and DKIM) at your domain registrar (where you bought the domain). No typos, no extra spaces.
- Wait 24–48 hours for DNS propagation, then in Resend click “Verify” again.

### 2. SPF, DKIM, and DMARC
- **SPF** and **DKIM**: Resend gives you these when you add the domain. Add them as instructed.
- **DMARC**: Add a TXT record for `_dmarc.yourdomain.com` (e.g. `_dmarc.jawadsoftware.com`) with value:
  - `v=DMARC1; p=none; rua=mailto:noreply@jawadsoftware.com`
  - Start with `p=none` (monitoring only). After a few weeks with no issues, you can move to `p=quarantine` then `p=reject`. Many inbox providers (Gmail, Yahoo, Outlook) now expect DMARC.

### 3. Use an address on that domain
- In `functions/.env`, `RESEND_FROM_EMAIL` must be an address **on the domain you verified** (e.g. `noreply@jawadsoftware.com` or `noreply@jawadsoftware.com`). Do **not** use `@gmail.com` or another domain you don’t control.

### 4. Redeploy after code/config changes
- After changing `functions/.env` or the function code, run:
  ```bash
  firebase deploy --only functions
  ```

### 5. Reputation and “warm-up”
- New domains have no reputation. Send only to real users (sign-up, password reset). Avoid test bursts to many addresses.
- Ask users to **mark the message as “Not spam”** or move it to Inbox the first time; that trains Gmail/Outlook for your domain.
- Check [Resend → Logs](https://resend.com/emails) for bounces or complaints and fix any issues (e.g. invalid addresses).

### 6. Check the actual sender
- In the spam message, open “Show original” or “View source” and confirm the **From** and **Reply-To** are your domain (e.g. `noreply@jawadsoftware.com`). If you see Resend’s or another domain, your Resend domain setup or `RESEND_FROM_EMAIL` is wrong.

---

**If you stay on the free Spark plan:** You cannot deploy Cloud Functions. The app will automatically use Firebase’s built-in verification and password-reset emails instead (they may still go to spam). To improve that, use **Option 1** below: customize the sender name and email templates in Firebase Console (Authentication → Templates).

---

## Why These Emails Go to Spam (when using Firebase only)

### 1. **Sender identity and domain**
- By default, Firebase uses a generic “no-reply” style sender (e.g. `noreply@your-project-id.firebaseapp.com` or Google’s mail servers).
- Many providers (Gmail, Outlook, etc.) treat unknown or generic senders as suspicious.
- If you haven’t set up a **custom domain** or proper branding, the “From” address looks impersonal and is more likely to be filtered.

### 2. **No custom domain / DNS records**
- When you don’t use your own domain for sending, you don’t control **SPF**, **DKIM**, or **DMARC** for that domain.
- Firebase/Google do set up authentication for their own domains, but:
  - Your app’s domain might not match the email domain.
  - Some providers still treat “firebaseapp.com” or similar as less trusted than a well-known brand domain.

### 3. **Content and format**
- Default Firebase email templates are plain and generic.
- Lack of a clear, trusted brand (logo, your domain, consistent styling) can increase spam score.
- Short, impersonal, or “robot-like” text can trigger filters.

### 4. **Recipient behavior**
- If many users mark the email as spam or never open it, providers learn to filter future messages from that sender.
- New projects have no sending history, so reputation starts neutral or low.

### 5. **Volume and patterns**
- Sudden spikes in sign-ups or password resets can look like abuse to some filters.
- Sending only transactional emails (verification + reset) is good, but without a good sender reputation it may still be filtered.

---

## How to Fix It

### Option 1: Use Firebase’s built-in options (quick wins)

#### A. Customize the sender name and templates (Firebase Console)
1. Open [Firebase Console](https://console.firebase.google.com) → your project.
2. Go to **Authentication** → **Templates** (or **Settings** → **Email**).
3. **Sender name**: Set a clear, recognizable name (e.g. `Tawfir Energy` or `Noor Energy`) instead of a generic “noreply”.
4. **Templates**: Edit the **Email address verification** and **Password reset** templates:
   - Use a clear subject (e.g. “Confirm your Tawfir Energy account”).
   - Add your app/product name and a short, professional message.
   - Avoid spammy words (“free”, “act now”, “click here” without context).
   - Prefer a simple HTML template with your logo and link, rather than raw plain text.

#### B. Use an authorized domain
- In **Authentication** → **Settings** → **Authorized domains**, ensure your app’s domain (and any custom link domain) is listed so links in emails are trusted.

These steps don’t change the underlying sending domain but improve trust and reduce spam flags.

---

### Option 2: Send from your own domain (best long-term)

To improve deliverability, send auth emails **from your own domain** (e.g. `noreply@jawadsoftware.com`) with proper DNS.

#### A. Custom domain in Firebase (if supported)
- Check Firebase docs for “custom email domain” or “SMTP” for Auth emails. When available, you:
  - Add your domain in the Firebase Console.
  - Add the DNS records Firebase gives you (SPF, DKIM, etc.) at your domain provider.

#### B. Use a custom SMTP / Email provider (e.g. SendGrid, Mailgun, SES)
- Firebase doesn’t natively let you plug in arbitrary SMTP for Auth emails. You have two approaches:
  1. **Firebase Extensions**: Use an extension that sends emails via a third-party (e.g. SendGrid, Resend) when a user is created or when you trigger a custom “password reset” flow. This usually requires a small Cloud Function + the extension.
  2. **Custom backend**: Replace Firebase’s built-in “send verification” and “send password reset” with your own backend that:
     - Calls Firebase Admin to generate verification/reset links or tokens.
     - Sends the email yourself via SendGrid, Mailgun, Amazon SES, etc., from your domain.

In both cases you then:
- Send from an address like `noreply@yourdomain.com`.
- Set **SPF**, **DKIM**, and **DMARC** for `yourdomain.com` as recommended by your email provider.
- Use their templates and best practices (plain text + HTML, clear subject, one main CTA).

---

### Option 3: Set up SPF, DKIM, and DMARC (when you send from your domain)

If you send from your own domain (via Firebase custom domain or your own SMTP), add these DNS records at your domain registrar.

| Record | Purpose |
|--------|--------|
| **SPF** | Tells inboxes which servers are allowed to send for `@yourdomain.com`. |
| **DKIM** | Adds a signature so inboxes can verify the email wasn’t modified. |
| **DMARC** | Tells inboxes what to do with mail that fails SPF/DKIM (none / quarantine / reject). |

- Your email provider (SendGrid, Mailgun, SES, or Firebase) will give you the exact values.
- Start with **SPF** and **DKIM**; add **DMARC** with `p=none` first, then move to `p=quarantine` or `p=reject` once you’re sure nothing is broken.

This doesn’t apply to the default Firebase sender domain (Google manages that), but it’s required for good deliverability when you use your own domain.

---

### Option 4: Content and behavior best practices

- **Subject line**: Clear and specific (e.g. “Verify your email – Tawfir Energy”, “Reset your Tawfir Energy password”).
- **Body**: One main action (e.g. “Verify email” or “Reset password”), your brand name, and a link. Avoid heavy marketing language.
- **Link**: Use the link Firebase (or your backend) provides; don’t shorten with random shorteners.
- **Consistency**: Same sender name and style across verification and password reset.
- **Testing**: Send to Gmail, Outlook, and Yahoo; check spam folder and fix any warnings (e.g. “Why is this message in Spam?”).

---

## Summary

| Cause | Fix |
|-------|-----|
| Generic sender / default templates | Customize sender name and email templates in Firebase Console. |
| No custom domain | When possible, send from your own domain and set SPF/DKIM/DMARC. |
| Poor content | Use clear subject, one CTA, your brand name, simple HTML. |
| Low reputation | Build volume gradually; avoid users marking as spam. |

**Quick path:**  
1. In Firebase Console, set a clear **sender name** and edit **Email verification** and **Password reset** templates.  
2. Add **authorized domains** and test with a few addresses.  

**Better long-term (already implemented in this project):**  
3. Use the **Cloud Functions + Resend** setup above so emails send from your domain with **SPF/DKIM** configured in Resend.

---

## References

- [Resend – Domains (verify & DNS)](https://resend.com/docs/dashboard/domains/introduction)
- [Resend – API keys](https://resend.com/api-keys)
- [Firebase Auth – Custom email handler](https://firebase.google.com/docs/auth/custom-email-handler)
- [Firebase – Generate email action links (Admin)](https://firebase.google.com/docs/auth/admin/email-action-links)
- [Firebase – Customize email templates](https://support.google.com/firebase/answer/7000714)
