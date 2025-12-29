# Tawfir Energy Admin Web Dashboard

Complete admin web dashboard for managing Tawfir Energy requests, applications, technicians, partners, and notifications.

## Features

✅ **Authentication**
- Firebase Auth login
- Hardcoded admin email: `admin@tawfir-energy.com`

✅ **Main Dashboard**
- Real-time statistics
- Total requests (Devis, Installation, Maintenance, Pumping)
- Pending applications count
- Active technicians and partners count

✅ **Requests Management**
- Devis Requests - View and manage all devis requests
- Installation Requests - Manage installation requests
- Maintenance Requests - Handle maintenance requests with urgency
- Pumping Requests - Manage pumping requests with mode

✅ **Applications Management**
- Technician Applications - Approve/Reject technician applications
- Partner Applications - Approve/Reject partner applications

✅ **Directory Management**
- Technicians - View and delete technicians
- Partners - View and delete partners

✅ **Notifications**
- View all admin notifications
- Mark notifications as read
- Real-time updates

## Project Structure

```
admin_dashboard/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── auth/
│   │   └── login_page.dart         # Login page
│   ├── dashboard/
│   │   └── main_dashboard.dart     # Main dashboard with sidebar
│   ├── requests/
│   │   ├── devis_requests_page.dart
│   │   ├── installation_requests_page.dart
│   │   ├── maintenance_requests_page.dart
│   │   └── pumping_requests_page.dart
│   ├── applications/
│   │   ├── technician_applications_page.dart
│   │   └── partner_applications_page.dart
│   ├── technicians/
│   │   └── technicians_page.dart
│   ├── partners/
│   │   └── partners_page.dart
│   ├── notifications/
│   │   └── notifications_page.dart
│   ├── services/
│   │   └── firestore_service.dart   # Firestore operations
│   ├── widgets/
│   │   ├── sidebar.dart             # Sidebar navigation
│   │   ├── topbar.dart              # Top app bar
│   │   └── request_detail_dialog.dart
│   └── utils/
│       ├── app_theme.dart           # Theme configuration
│       ├── date_formatter.dart       # Date formatting utilities
│       └── status_chip.dart         # Status badge widget
├── web/
│   ├── index.html                   # Web entry point
│   └── manifest.json                # PWA manifest
└── pubspec.yaml                     # Dependencies
```

## Setup Instructions

### 1. Configure Firebase

Edit `lib/main.dart` and add your Firebase configuration:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  ),
);
```

Also update `web/index.html` with your Firebase config in the script tag.

### 2. Create Admin User

Create an admin user in Firebase Authentication with email: `admin@tawfir-energy.com`

### 3. Install Dependencies

```bash
cd admin_dashboard
flutter pub get
```

### 4. Run the App

```bash
flutter run -d chrome
```

Or for web server:
```bash
flutter run -d web-server --web-port=8080
```

## Deployment

### Build for Web

```bash
flutter build web
```

This creates a `build/web` folder with all static files.

### Deploy Options

**Option 1: Firebase Hosting**
```bash
firebase init hosting
# Select build/web as public directory
firebase deploy --only hosting
```

**Option 2: Netlify**
- Connect your repository
- Build command: `cd admin_dashboard && flutter build web`
- Publish directory: `admin_dashboard/build/web`

**Option 3: Vercel**
- Import project
- Build command: `cd admin_dashboard && flutter build web`
- Output directory: `admin_dashboard/build/web`

**Option 4: GitHub Pages**
```bash
cd admin_dashboard
flutter build web
# Copy build/web contents to gh-pages branch
```

## Routes Structure

The app uses a single-page application (SPA) structure with sidebar navigation:

- `/` - Dashboard Home (index 0)
- Devis Requests (index 1)
- Installation Requests (index 2)
- Maintenance Requests (index 3)
- Pumping Requests (index 4)
- Technician Applications (index 5)
- Partner Applications (index 6)
- Technicians (index 7)
- Partners (index 8)
- Notifications (index 9)

## Firestore Collections Used

- `devis_requests` - Devis requests
- `installation_requests` - Installation requests
- `maintenance_requests` - Maintenance requests
- `pumping_requests` - Pumping requests
- `technician_applications` - Technician applications
- `partner_applications` - Partner applications
- `technicians` - Approved technicians
- `partners` - Approved partners
- `notifications` - Admin notifications

## Security Rules

Make sure your Firestore security rules allow admin access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin access - adjust based on your auth setup
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Features Details

### Real-time Updates
All pages use `StreamBuilder` with Firestore streams for real-time data updates.

### Status Management
- Change request status: Pending, Approved, Rejected, Assigned
- Approve/Reject applications
- Delete technicians and partners

### Notifications
- View all admin notifications
- Mark as read
- Color-coded by read/unread status

## Troubleshooting

**Firebase not initialized:**
- Check Firebase config in `main.dart` and `index.html`
- Ensure Firebase project is set up correctly

**Authentication issues:**
- Verify admin user exists in Firebase Auth
- Check email matches: `admin@tawfir-energy.com`

**No data showing:**
- Verify Firestore collections exist
- Check Firestore security rules
- Ensure Firebase project matches mobile app

## Development Notes

- Uses Material Design 3
- Responsive layout
- Real-time Firestore streams
- Professional UI with sidebar navigation
- Status chips for visual status indication
- Date formatting in French locale

