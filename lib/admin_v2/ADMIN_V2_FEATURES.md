# Admin Dashboard V2 - Complete Features List

This document lists all features that should be implemented in the new Admin Dashboard V2, based on analysis of the existing app and admin dashboard.

---

## 📊 **1. DASHBOARD PAGE**

### Overview Statistics
- **Total Counts Display:**
  - Total Devis Requests
  - Total Installation Requests
  - Total Maintenance Requests
  - Total Pumping Requests
  - Total Project Requests (Études & Projets)
  - Pending Technician Applications (with badge indicator)
  - Pending Partner Applications (with badge indicator)
  - Active Technicians Count
  - Active Partners Count

### Statistics Cards
- **Visual Cards:** Each stat in a card with:
  - Icon representing the category
  - Large number display
  - Title label
  - Optional growth indicator (e.g., "+12%")
  - Pending badge for applications
  - Color coding (primary, success, warning, info)

### Real-time Updates
- **StreamBuilder:** All statistics update in real-time from Firestore
- **Auto-refresh:** Statistics reload when returning to dashboard

---

## 📋 **2. DEVIS REQUESTS PAGE**

### Data Display
- **Table Columns:**
  - Date (formatted: relative time or absolute)
  - Nom (fullName or name)
  - Téléphone (phone)
  - Ville (city)
  - Type Système (systemType: On-grid, Off-grid, Hybride, Pompe)
  - Puissance (powerKW in kW)
  - Panneaux (panels count)
  - Économies/Mois (savingsMonth)
  - Économies/An (savingsYear)
  - Région (regionCode)
  - GPS (gps coordinates)
  - Note (note/comment)
  - Statut (status chip)
  - Actions (view, status menu)

### Data Fields (from Firestore)
- `id` - Document ID
- `date` or `createdAt` - Request date
- `fullName` or `name` - Client name
- `phone` or `phoneNumber` - Phone number
- `city` - City name
- `gps` - GPS coordinates
- `note` - Additional notes
- `systemType` - System type
- `regionCode` - Region code
- `kwhMonth` - Monthly consumption in kWh
- `powerKW` - Calculated power in kW
- `panels` - Number of panels
- `savingsMonth` - Monthly savings
- `savingsYear` - Annual savings
- `status` - pending, approved, rejected, assigned
- `userId` - User ID (if logged in)

### Actions Available
- **View Details:** Open modal/dialog with all request details
- **Status Management:**
  - Change to: Pending, Approved, Rejected, Assigned
  - Status chips with color coding
- **Technician Assignment:**
  - Assign technician to request
  - View assigned technician info
  - Unassign technician
- **Bulk Actions:**
  - Select multiple requests
  - Bulk status update
  - Bulk approve/reject

### Filters & Search
- **Search Bar:** Search by name, phone, city
- **Status Filter:** Dropdown (All, Pending, Approved, Rejected, Assigned)
- **Date Range Filter:** Start date and end date picker
- **Region Filter:** Filter by city/region
- **Advanced Filters Panel:** Expandable panel with all filters

### Export Features
- **Export to Excel:** Download as .xlsx file
- **Export to CSV:** Download as .csv file
- **Export to PDF:** Generate PDF report
- **Print:** Print current filtered data
- **Export filtered data:** Only export visible/filtered results

---

## 🔧 **3. INSTALLATION REQUESTS PAGE**

### Data Display
- **Table Columns:**
  - Date
  - Nom
  - Téléphone
  - Ville
  - Type Système (On-grid, Off-grid, Hybride, Pompe)
  - Type Localisation (Maison, Entreprise, Ferme, Autre)
  - Description
  - Photos (count or thumbnail)
  - Statut
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Request date
- `name` - Client name
- `phone` - Phone number
- `city` - City
- `systemType` - System type
- `locationType` - Location type
- `description` - Problem/request description
- `location` - Physical location
- `photoUrls` - Array of photo URLs
- `status` - pending, approved, rejected, assigned, in_progress, completed
- `userId` - User ID
- `assignedTechnician` - Assigned technician object
- `assignedAt` - Assignment timestamp

### Actions Available
- **View Details:** Full request details with photos
- **Status Management:** Change status
- **Technician Assignment:** Assign/unassign technician
- **Photo Viewing:** View uploaded photos in gallery
- **Bulk Actions:** Multi-select operations

### Filters & Search
- Same as Devis Requests (Search, Status, Date Range, Region)

### Export Features
- Same as Devis Requests (Excel, CSV, PDF, Print)

---

## 🛠️ **4. MAINTENANCE REQUESTS PAGE**

### Data Display
- **Table Columns:**
  - Date
  - Nom
  - Téléphone
  - Ville
  - Urgence (High, Medium, Normal) - Color coded
  - Description
  - Statut
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Request date
- `name` - Client name
- `phone` - Phone number
- `city` - City
- `problemDescription` or `description` - Problem description
- `urgency` - high, medium, normal (or haute, moyenne, normale)
- `location` - Physical location
- `status` - pending, approved, rejected, assigned, in_progress, completed
- `userId` - User ID
- `assignedTechnician` - Assigned technician
- `assignedAt` - Assignment timestamp

### Special Features
- **Urgency Indicator:** Color-coded urgency badges
- **Priority Sorting:** Sort by urgency level
- **Urgency Filter:** Filter by urgency (High, Medium, Normal)

### Actions Available
- **View Details:** Full request details
- **Status Management:** Change status
- **Technician Assignment:** Assign technician
- **Urgency Update:** Change urgency level
- **Bulk Actions:** Multi-select operations

### Filters & Search
- Search, Status, Date Range, Region, **Urgency Filter**

### Export Features
- Excel, CSV, PDF, Print

---

## 💧 **5. PUMPING REQUESTS PAGE**

### Data Display
- **Table Columns:**
  - Date
  - Nom
  - Téléphone
  - Ville
  - Mode (pumping mode)
  - Débit (Q) - Flow rate
  - Hauteur (H) - Height
  - Puissance Pompe (pumpKW)
  - Puissance PV (pvPower)
  - Panneaux (panels)
  - Économies/Mois (savingMonth)
  - Économies/An (savingYear)
  - GPS
  - Note
  - Statut
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Request date
- `name` - Client name
- `phone` - Phone number
- `city` - City
- `gps` - GPS coordinates
- `note` - Additional notes
- `q` - Flow rate (débit)
- `h` - Height (hauteur)
- `pumpKW` - Pump power in kW
- `pvPower` - PV power in kW
- `panels` - Number of panels
- `savingMonth` - Monthly savings
- `savingYear` - Annual savings
- `regionCode` - Region code
- `mode` - Pumping mode
- `status` - pending, approved, rejected, assigned
- `userId` - User ID

### Actions Available
- **View Details:** Full request with all calculations
- **Status Management:** Change status
- **Technician Assignment:** Assign technician
- **Bulk Actions:** Multi-select operations

### Filters & Search
- Search, Status, Date Range, Region

### Export Features
- Excel, CSV, PDF, Print

---

## 📐 **6. PROJECT REQUESTS PAGE (Études & Projets)**

### Data Display
- **Table Columns:**
  - Date
  - Nom (name or fullName)
  - Téléphone (phone or phoneNumber)
  - Ville (city)
  - Type Projet (projectType: ON-GRID, OFF-GRID, HYBRID, PUMPING)
  - Consommation (consumption)
  - Unité (isKwh: kWh or kW)
  - Puissance Estimée (estimatedPower in kW)
  - Puissance Panneau (panelPower in W)
  - Statut
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Request date
- `name` or `fullName` - Client name
- `phone` or `phoneNumber` - Phone number
- `city` - City
- `projectType` - ON-GRID, OFF-GRID, HYBRID, PUMPING
- `consumption` - Consumption value
- `isKwh` - Boolean: true if kWh, false if kW
- `estimatedPower` - Estimated power in kW
- `panelPower` - Panel power in watts
- `status` - pending, approved, rejected, assigned
- `userId` - User ID

### Actions Available
- **View Details:** Full project details
- **Status Management:** Change status
- **Technician Assignment:** Assign technician
- **Bulk Actions:** Multi-select operations

### Filters & Search
- Search, Status, Date Range, Region, **Project Type Filter**

### Export Features
- Excel, CSV, PDF, Print

---

## 👤 **7. TECHNICIAN APPLICATIONS PAGE**

### Data Display
- **Table Columns:**
  - Date
  - Nom
  - Téléphone
  - Ville
  - Email
  - Spécialité (speciality)
  - Statut (pending, approved, rejected)
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Application date
- `name` - Technician name
- `phone` - Phone number
- `city` - City
- `email` - Email address
- `speciality` - Speciality/area of expertise
- `status` - pending, approved, rejected
- `updatedAt` - Last update timestamp

### Actions Available
- **View Details:** Full application details
- **Approve Application:**
  - Creates entry in `technicians` collection
  - Sets status to 'approved'
  - Creates notification
- **Reject Application:**
  - Sets status to 'rejected'
  - Creates notification
- **Bulk Actions:** Approve/reject multiple applications

### Filters & Search
- Search by name, phone, city, email
- Status filter (Pending, Approved, Rejected)
- Date range filter
- Region filter

### Export Features
- Excel, CSV, PDF, Print

---

## 🏢 **8. PARTNER APPLICATIONS PAGE**

### Data Display
- **Table Columns:**
  - Date
  - Entreprise (companyName or name)
  - Téléphone
  - Ville
  - Email
  - Spécialité
  - Statut
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Application date
- `companyName` or `name` - Company name
- `phone` - Phone number
- `city` - City
- `email` - Email address
- `speciality` - Speciality
- `status` - pending, approved, rejected
- `updatedAt` - Last update timestamp

### Actions Available
- **View Details:** Full application details
- **Approve Application:**
  - Creates entry in `partners` collection
  - Sets status to 'approved'
- **Reject Application:**
  - Sets status to 'rejected'
- **Bulk Actions:** Approve/reject multiple

### Filters & Search
- Same as Technician Applications

### Export Features
- Excel, CSV, PDF, Print

---

## 👥 **9. TECHNICIANS MANAGEMENT PAGE**

### Data Display
- **Table Columns:**
  - Date Ajout (createdAt)
  - Nom
  - Téléphone
  - Ville
  - Email
  - Spécialité
  - Statut (Active/Inactive)
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Creation date
- `name` - Technician name
- `phone` - Phone number
- `city` - City
- `email` - Email
- `speciality` - Speciality
- `active` - Boolean: true/false

### Actions Available
- **Edit Technician:** Update technician information
- **Delete Technician:** Remove from directory (with confirmation)
- **Toggle Active Status:** Activate/deactivate technician
- **View Assignments:** See all requests assigned to this technician
- **Contact:** Quick contact (phone, email)

### Filters & Search
- Search by name, phone, city, email, speciality
- Active/Inactive filter
- Region filter

### Export Features
- Excel, CSV, PDF, Print

---

## 🏭 **10. PARTNERS MANAGEMENT PAGE**

### Data Display
- **Table Columns:**
  - Date Ajout
  - Entreprise (companyName or name)
  - Téléphone
  - Ville
  - Email
  - Spécialité
  - Statut (Active/Inactive)
  - Actions

### Data Fields
- `id` - Document ID
- `createdAt` - Creation date
- `companyName` or `name` - Company name
- `phone` - Phone number
- `city` - City
- `email` - Email
- `speciality` - Speciality
- `active` - Boolean: true/false

### Actions Available
- **Edit Partner:** Update partner information
- **Delete Partner:** Remove from directory (with confirmation)
- **Toggle Active Status:** Activate/deactivate partner
- **Contact:** Quick contact

### Filters & Search
- Same as Technicians Management

### Export Features
- Excel, CSV, PDF, Print

---

## 🔔 **11. NOTIFICATIONS PAGE**

### Data Display
- **Notification List:**
  - Icon (type-based)
  - Title
  - Message
  - Date/Time (relative or absolute)
  - Seen/Unseen indicator (badge)
  - Request link (if applicable)

### Notification Types
- `devisRequest` - New devis request
- `installationRequest` - New installation request
- `maintenanceRequest` - New maintenance request
- `pumpingRequest` - New pumping request
- `technicianApplication` - New technician application
- `partnerApplication` - New partner application
- `statusUpdate` - Status changed
- `technicianAssigned` - Technician assigned to request

### Data Fields
- `id` - Document ID
- `type` - Notification type
- `title` - Notification title
- `message` - Notification message
- `user` - 'admin' or userId
- `date` or `createdAt` - Notification date
- `seen` - Boolean: true/false
- `requestId` - Related request ID
- `requestCollection` - Related collection name
- `seenAt` - When notification was seen

### Actions Available
- **Mark as Read:** Mark notification as seen
- **Mark All as Read:** Mark all notifications as read
- **Navigate to Request:** Click to go to related request
- **Delete Notification:** Remove notification
- **Filter by Type:** Filter by notification type
- **Unread Count Badge:** Show count of unread notifications

### Features
- **Real-time Updates:** New notifications appear automatically
- **Unread Indicator:** Visual indicator for unread notifications
- **Grouping:** Group by date (Today, Yesterday, This Week, Older)
- **Pagination:** Load more notifications

---

## 🔍 **12. SEARCH & FILTER FEATURES**

### Global Search (Top Bar)
- **Search Across All Collections:**
  - Search requests by name, phone, city
  - Search technicians/partners
  - Search applications
  - Real-time search results
  - Search history (optional)

### Advanced Filters Panel
- **Available Filters:**
  - **Status Filter:** Dropdown (All, Pending, Approved, Rejected, Assigned)
  - **Date Range Filter:** Start date and end date picker
  - **Region/City Filter:** Dropdown with city list
  - **Search Query:** Text input with debouncing
  - **Expandable Panel:** Collapse/expand filters
  - **Clear Filters:** Reset all filters button
  - **Filter Count Badge:** Show number of active filters

### Request-Specific Filters
- **Devis Requests:**
  - System Type filter (On-grid, Off-grid, Hybride, Pompe)
  - Power range filter (min/max kW)
  - Region filter
- **Maintenance Requests:**
  - Urgency filter (High, Medium, Normal)
  - Status filter
- **Project Requests:**
  - Project Type filter (ON-GRID, OFF-GRID, HYBRID, PUMPING)
  - Consumption range filter

---

## 📤 **13. EXPORT & PRINT FEATURES**

### Export Formats
- **Excel (.xlsx):**
  - All columns included
  - Formatted table
  - Downloadable file
- **CSV (.csv):**
  - Comma-separated values
  - Downloadable file
- **PDF (.pdf):**
  - Formatted report
  - Header with company logo
  - Footer with page numbers
  - Print-ready format
- **Print:**
  - Browser print dialog
  - Formatted for printing

### Export Options
- **Export Filtered Data:** Only export visible/filtered results
- **Export All Data:** Export entire collection
- **Custom Columns:** Select which columns to export
- **Date Range in Filename:** Include date range in filename
- **Export Bar:** Visible on all request pages

---

## ⚙️ **14. STATUS MANAGEMENT**

### Status Types
- **Pending (En attente):** Yellow/Warning color
- **Approved (Approuvé):** Green/Success color
- **Rejected (Rejeté):** Red/Error color
- **Assigned (Assigné):** Blue/Info color
- **In Progress (En cours):** Orange color (for installation/maintenance)
- **Completed (Terminé):** Green color (for installation/maintenance)

### Status Actions
- **Change Status:** Dropdown menu or popup menu
- **Bulk Status Update:** Update multiple requests at once
- **Status History:** Track status changes (optional)
- **Status Change Notification:** Create notification when status changes

---

## 👨‍🔧 **15. TECHNICIAN ASSIGNMENT**

### Assignment Features
- **Assign Technician:**
  - Modal/dialog to select technician
  - List of active technicians
  - Search technicians by name/city
  - Assign to request
  - Update status to 'assigned'
- **View Assigned Technician:**
  - Display technician name, phone, city
  - Quick contact buttons
  - View technician profile
- **Unassign Technician:**
  - Remove assignment
  - Reset status
- **Reassign Technician:**
  - Change assigned technician

### Assignment Data
- `assignedTechnician` - Object with:
  - `id` - Technician document ID
  - `name` - Technician name
  - `phone` - Phone number
  - `city` - City
- `assignedAt` - Assignment timestamp

---

## 📊 **16. ANALYTICS & REPORTS (Future Enhancement)**

### Dashboard Analytics
- **Charts & Graphs:**
  - Requests over time (line chart)
  - Status distribution (pie chart)
  - Requests by region (bar chart)
  - Monthly trends
- **Performance Metrics:**
  - Average response time
  - Completion rate
  - Technician workload
  - Regional distribution

### Reports
- **Daily Report:** Summary of daily activities
- **Weekly Report:** Weekly statistics
- **Monthly Report:** Monthly summary
- **Custom Reports:** Date range reports

---

## 🔐 **17. AUTHENTICATION & SECURITY**

### Login Features
- **Firebase Auth Login:**
  - Email/password authentication
  - Admin email check
  - Session management
- **Logout:**
  - Clear session
  - Redirect to login

### Security
- **Role-based Access:** Only admin users can access
- **Session Timeout:** Auto-logout after inactivity (optional)
- **Activity Logging:** Log admin actions (optional)

---

## 🎨 **18. UI/UX FEATURES**

### Layout
- **Responsive Design:**
  - Desktop (full sidebar)
  - Tablet (collapsible sidebar)
  - Mobile (drawer menu)
- **Fixed Sidebar:** Always visible navigation
- **Top Bar:** Search, notifications, profile
- **Main Content Area:** Scrollable, fills available space

### Interactions
- **Page Transitions:** Smooth page switching
- **Loading States:** Skeleton loaders or spinners
- **Empty States:** Friendly messages when no data
- **Error Handling:** User-friendly error messages
- **Success Feedback:** Snackbars for actions

### Visual Elements
- **Status Chips:** Color-coded status badges
- **Icons:** Meaningful icons for actions
- **Color Coding:**
  - Primary: Blue (#0175C2)
  - Success: Green (#4CAF50)
  - Warning: Orange (#FF9800)
  - Error: Red (#F44336)
  - Info: Light Blue (#2196F3)

---

## 📱 **19. REAL-TIME FEATURES**

### Real-time Updates
- **StreamBuilder:** All pages use StreamBuilder for real-time data
- **Auto-refresh:** Data updates automatically
- **Live Counts:** Statistics update in real-time
- **Notification Badges:** Update in real-time

---

## 🔄 **20. BULK OPERATIONS**

### Bulk Actions
- **Multi-select:** Checkbox selection for multiple items
- **Select All:** Select all items on current page
- **Bulk Status Update:** Update status for multiple requests
- **Bulk Approve/Reject:** Approve or reject multiple applications
- **Bulk Delete:** Delete multiple items (with confirmation)
- **Bulk Export:** Export selected items only

---

## 📝 **21. DETAIL VIEWS**

### Request Detail Dialog/Modal
- **All Fields Display:**
  - Client information (name, phone, email, city)
  - Request details (system type, power, panels, etc.)
  - Dates (created, updated, assigned)
  - Status and history
  - Assigned technician info
  - GPS location (if available)
  - Photos (if available)
  - Notes/comments
- **Actions in Dialog:**
  - Change status
  - Assign technician
  - Edit (optional)
  - Close

---

## 🗂️ **22. DATA ORGANIZATION**

### Sorting
- **Default Sort:** By creation date (newest first)
- **Sortable Columns:** Click column header to sort
- **Sort Options:**
  - Date (ascending/descending)
  - Name (A-Z, Z-A)
  - Status
  - City

### Pagination
- **Rows Per Page:** 10, 15, 25, 50, 100
- **Page Navigation:** Previous, Next, Page numbers
- **Total Count:** Display total items and current range

---

## 🔗 **23. INTEGRATION FEATURES**

### Firestore Collections
- `devis_requests` - Devis requests
- `installation_requests` - Installation requests
- `maintenance_requests` - Maintenance requests
- `pumping_requests` - Pumping requests
- `project_requests` - Project study requests
- `technician_applications` - Technician applications
- `partner_applications` - Partner applications
- `technicians` - Active technicians directory
- `partners` - Active partners directory
- `notifications` - Admin notifications
- `users` - User profiles (optional: user management)

### Firebase Services
- **Firestore:** Real-time database
- **Firebase Auth:** Authentication
- **Cloud Functions:** (optional) Server-side operations

---

## ✅ **24. IMPLEMENTATION CHECKLIST**

### Core Pages
- [x] Dashboard Page
- [x] Devis Requests Page
- [x] Installation Requests Page
- [x] Maintenance Requests Page
- [x] Pumping Requests Page
- [x] Project Requests Page
- [x] Technician Applications Page
- [x] Partner Applications Page
- [x] Technicians Management Page
- [x] Partners Management Page
- [x] Notifications Page

### Features to Implement
- [ ] Advanced Filters Panel (status, date range, region, search)
- [ ] Export Bar (Excel, CSV, PDF, Print)
- [ ] Request Detail Dialog (view all fields)
- [ ] Technician Assignment Modal
- [ ] Bulk Actions (multi-select, bulk update)
- [ ] Status Management (change status, status chips)
- [ ] Search Functionality (global and per-page)
- [ ] Pagination (rows per page, page navigation)
- [ ] Sorting (sortable columns)
- [ ] Real-time Updates (StreamBuilder on all pages)
- [ ] Notification System (mark as read, navigate to request)
- [ ] Approve/Reject Applications (with Firestore updates)
- [ ] Delete Technicians/Partners (with confirmation)
- [ ] Edit Technicians/Partners (update information)
- [ ] Toggle Active Status (activate/deactivate)

### UI Components
- [x] Sidebar Navigation
- [x] Top Bar (search, notifications, profile)
- [x] Simple Data Table (ListView-based)
- [x] Status Chip Widget
- [x] Date Formatter
- [ ] Advanced Filters Panel Widget
- [ ] Export Bar Widget
- [ ] Request Detail Dialog Widget
- [ ] Technician Assignment Modal Widget
- [ ] Bulk Action Bar Widget
- [ ] Pagination Widget
- [ ] Loading Skeleton Widget
- [ ] Empty State Widget

### Services
- [x] Firestore Service (streams, updates, statistics)
- [ ] Export Service (Excel, CSV, PDF, Print)
- [ ] Notification Service (mark as read, create notifications)

---

## 🎯 **25. PRIORITY FEATURES**

### High Priority (Must Have)
1. ✅ All 11 pages with data display
2. ✅ Real-time data streaming
3. ✅ Status management (change status)
4. ✅ View request details
5. ✅ Search functionality
6. ✅ Basic filters (status, search)
7. ✅ Export to Excel/CSV
8. ✅ Approve/Reject applications
9. ✅ Delete technicians/partners

### Medium Priority (Should Have)
1. Advanced filters (date range, region)
2. Technician assignment
3. Bulk actions
4. Export to PDF
5. Print functionality
6. Notification management
7. Edit technicians/partners
8. Pagination
9. Sorting

### Low Priority (Nice to Have)
1. Analytics and charts
2. Custom reports
3. Activity logging
4. Status history
5. Advanced search
6. Export custom columns
7. Dashboard widgets customization

---

## 📚 **26. DATA FIELD REFERENCE**

### Common Fields (All Requests)
- `id` - Document ID
- `createdAt` - Creation timestamp
- `updatedAt` - Update timestamp (optional)
- `status` - Request status
- `userId` - User ID (if logged in)
- `name` or `fullName` - Client name
- `phone` or `phoneNumber` - Phone number
- `city` - City name
- `assignedTechnician` - Assigned technician object (optional)
- `assignedAt` - Assignment timestamp (optional)

### Devis Request Specific
- `date` - Request date
- `gps` - GPS coordinates
- `note` - Additional notes
- `systemType` - System type
- `regionCode` - Region code
- `kwhMonth` - Monthly consumption
- `powerKW` - Calculated power
- `panels` - Number of panels
- `savingsMonth` - Monthly savings
- `savingsYear` - Annual savings

### Installation Request Specific
- `systemType` - System type
- `locationType` - Location type
- `description` - Description
- `location` - Physical location
- `photoUrls` - Array of photo URLs

### Maintenance Request Specific
- `problemDescription` or `description` - Problem description
- `urgency` - Urgency level
- `location` - Physical location

### Pumping Request Specific
- `gps` - GPS coordinates
- `note` - Additional notes
- `q` - Flow rate (débit)
- `h` - Height (hauteur)
- `pumpKW` - Pump power
- `pvPower` - PV power
- `panels` - Number of panels
- `savingMonth` - Monthly savings
- `savingYear` - Annual savings
- `regionCode` - Region code
- `mode` - Pumping mode

### Project Request Specific
- `projectType` - ON-GRID, OFF-GRID, HYBRID, PUMPING
- `consumption` - Consumption value
- `isKwh` - Boolean: kWh or kW
- `estimatedPower` - Estimated power
- `panelPower` - Panel power in watts

---

## 🔄 **27. WORKFLOWS**

### Request Management Workflow
1. **New Request Arrives** → Appears in admin dashboard
2. **Admin Views Request** → Opens detail dialog
3. **Admin Reviews Details** → Checks all information
4. **Admin Changes Status** → Updates to Approved/Rejected
5. **Admin Assigns Technician** → Selects technician from list
6. **Technician Completes Work** → Status updated to Completed
7. **Request Archived** → Moved to completed/history (optional)

### Application Approval Workflow
1. **Application Submitted** → Appears in Applications page
2. **Admin Reviews Application** → Views all details
3. **Admin Approves** → Creates entry in technicians/partners collection
4. **Admin Rejects** → Updates status to rejected
5. **Notification Created** → Admin notified of action

---

## 📋 **28. TECHNICAL REQUIREMENTS**

### Flutter Web Compatibility
- ✅ Single Scaffold (no nested Scaffolds)
- ✅ Proper layout constraints (LayoutBuilder, Expanded)
- ✅ No Navigator.push for page switching
- ✅ State-based navigation
- ✅ All pages fill available space
- ✅ No gray/empty areas

### Performance
- **Debounced Search:** 300ms delay
- **Pagination:** Load data in chunks
- **Lazy Loading:** Load data as needed
- **Optimized Queries:** Indexed Firestore queries

### Error Handling
- **Network Errors:** User-friendly messages
- **Firestore Errors:** Error dialogs
- **Validation Errors:** Form validation feedback
- **Empty States:** Friendly empty state messages

---

## 🎨 **29. DESIGN SPECIFICATIONS**

### Colors
- **Primary:** #0175C2 (Blue)
- **Secondary:** #03A9F4 (Light Blue)
- **Success:** #4CAF50 (Green)
- **Warning:** #FF9800 (Orange)
- **Error:** #F44336 (Red)
- **Info:** #2196F3 (Light Blue)
- **Background:** #F5F5F5 (Light Gray)
- **Card:** #FFFFFF (White)
- **Text Primary:** #212121 (Dark Gray)
- **Text Secondary:** #757575 (Medium Gray)

### Typography
- **Page Title:** 32px, Bold
- **Section Title:** 18px, Semi-bold
- **Body Text:** 14px, Regular
- **Small Text:** 12px, Regular
- **Table Header:** 13px, Semi-bold
- **Table Data:** 14px, Regular

### Spacing
- **Page Padding:** 32px
- **Card Padding:** 24px
- **Element Spacing:** 16px, 24px, 32px
- **Table Cell Padding:** 16px

---

## 📝 **30. NOTES & CONSIDERATIONS**

### Important Notes
- **DataTable2 Issue:** Use SimpleDataTable (ListView-based) instead of DataTable2 to avoid rendering issues on Flutter Web
- **Locale Initialization:** Must initialize date formatting for French locale
- **Real-time Updates:** All pages use StreamBuilder for live data
- **State Management:** Use setState for local state, StreamBuilder for Firestore data
- **Error Handling:** Always check for null values and handle errors gracefully
- **Performance:** Use pagination for large datasets
- **Responsive:** Ensure layout works on different screen sizes

### Future Enhancements
- User management (view/edit users)
- Role-based permissions
- Activity audit log
- Advanced analytics dashboard
- Email notifications
- SMS notifications
- Custom fields per request type
- Request comments/notes
- File attachments
- Calendar view
- Gantt chart for assignments

---

**Last Updated:** Based on app analysis and existing admin dashboard
**Version:** 1.0
**Status:** Feature specification complete
