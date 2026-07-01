# Fix: Admin panel images not loading (CORS)

The admin panel runs in the browser. When it loads images from Firebase Storage, the browser blocks them unless the **Storage bucket allows cross-origin requests (CORS)**.

## Fix: Set CORS on your new project’s bucket

Use **Google Cloud Shell** (easiest, no local install):

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Select project **solar-app-f698e** (top bar).
3. Click the **Cloud Shell** icon (terminal) at the top right.
4. In Cloud Shell, run:

```bash
echo '[{"origin": ["*"], "method": ["GET", "HEAD", "PUT", "POST", "DELETE"], "maxAgeSeconds": 3600, "responseHeader": ["Content-Type", "Content-Length", "Content-Disposition", "Access-Control-Allow-Origin"]}]' > cors.json
gsutil cors set cors.json gs://solar-app-f698e.firebasestorage.app
```

If that bucket name fails, try:

```bash
gsutil cors set cors.json gs://solar-app-f698e.appspot.com
```

5. Wait for the command to finish. Then refresh the admin page and try again.

## Check your bucket name

- Firebase Console → **Storage** → look at the bucket name at the top (e.g. `solar-app-f698e.firebasestorage.app`).
- Use that exact name in the `gsutil cors set` command.

After CORS is set, product images and technician certificate images should load in the admin panel.
