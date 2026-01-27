# Admin Dashboard V2

A complete, working Flutter Web admin dashboard built from scratch with all features from the old admin.

## Usage

Simply use it in your MaterialApp:

```dart
import 'package:your_app/admin_v2/admin_layout.dart';

MaterialApp(
  home: AdminLayoutV2(),
)
```

## Structure

```
lib/admin_v2/
├── admin_layout.dart          # Main layout (Single Scaffold)
├── sidebar.dart               # Sidebar navigation with all menu items
├── topbar.dart                # Top bar with search and profile
├── services/
│   └── firestore_service.dart # Firestore integration
├── utils/
│   ├── app_theme.dart        # Theme colors
│   ├── status_chip.dart      # Status badge widget
│   └── date_formatter.dart   # Date formatting utilities
├── widgets/
│   └── simple_data_table.dart # Simple table widget (works on Flutter Web)
└── pages/
    ├── dashboard_page.dart              # Dashboard with statistics
    ├── devis_page.dart                  # Devis requests
    ├── installation_page.dart           # Installation requests
    ├── maintenance_page.dart            # Maintenance requests
    ├── pumping_page.dart                # Pumping requests
    ├── project_page.dart                 # Project requests
    ├── technician_applications_page.dart # Technician applications
    ├── partner_applications_page.dart    # Partner applications
    ├── technicians_page.dart            # Technicians management
    ├── partners_page.dart               # Partners management
    └── notifications_page.dart          # Notifications
```

## Key Features

- ✅ **Single Scaffold** - Only ONE Scaffold in entire admin
- ✅ **State-based navigation** - No Navigator.push, instant page switching
- ✅ **Proper Flutter Web constraints** - All pages use LayoutBuilder
- ✅ **No gray/blank pages** - All pages fill available space correctly
- ✅ **Firestore integration** - Real-time data streaming
- ✅ **All pages from old admin** - Complete feature parity
- ✅ **Simple table widget** - Uses ListView instead of DataTable2 (no rendering issues)
- ✅ **Clean, professional UI** - Similar design to old admin but better

## Design Principles

1. **Single Scaffold**: Only ONE Scaffold in the entire admin
2. **Row Layout**: Sidebar (fixed 260px) + Expanded (content)
3. **LayoutBuilder**: All pages use LayoutBuilder for constraints
4. **mainAxisSize.max**: All Columns use mainAxisSize.max
5. **Expanded**: Content areas use Expanded to fill space
6. **SizedBox.expand**: Main content wrapped in SizedBox.expand
7. **SimpleDataTable**: Custom table widget using ListView (works perfectly on Flutter Web)

## Pages Included

### Requests (Demandes)
- Dashboard - Statistics overview
- Devis - Quote requests
- Installation - Installation requests
- Maintenance - Maintenance requests
- Pompage - Pumping requests
- Études & Projets - Project requests

### Applications (Candidatures)
- Techniciens - Technician applications
- Partenaires - Partner applications

### Management (Gestion)
- Techniciens - Active technicians management
- Partenaires - Active partners management
- Notifications - Admin notifications

## Testing

Run on Flutter Web:
```bash
flutter run -d chrome
```

The dashboard will work immediately with:
- ✅ No gray pages
- ✅ No layout constraint issues
- ✅ All data rendering correctly
- ✅ Smooth page transitions
- ✅ Real-time Firestore updates

## Differences from Old Admin

1. **No DataTable2** - Uses custom SimpleDataTable (ListView-based) to avoid rendering issues
2. **Better constraints** - All pages properly constrained for Flutter Web
3. **Cleaner code** - Fresh implementation, no legacy code
4. **Same functionality** - All features from old admin included
