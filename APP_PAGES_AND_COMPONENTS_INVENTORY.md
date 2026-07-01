# App Pages & Components Inventory

This document lists all main app pages and reusable components, with **Arabic translation** and **Dark mode** support status.

**Legend:**
- **Arabic:** ✅ = Uses `AppLocalizations` (FR/EN/AR), ❌ = Hardcoded or no l10n, ⚠️ = Partial
- **Dark mode:** ✅ = Uses `Theme.of(context).colorScheme` / `scaffoldBackgroundColor`, ❌ = Not applied

---

## 1. Pages (Screens & Routes)

### 1.1 Auth
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Login (main) | `auth/.../login_page.dart` | ✅ | ✅ |
| Login (alt) | `auth/.../login_screen.dart` | ✅ | ✅ |
| Sign up | `auth/.../signup_page.dart` | ✅ | ✅ |
| Register | `auth/.../register_page.dart` | ✅ | ✅ |

### 1.2 Home
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Home (main) | `home/.../home_screen.dart` | ✅ | ✅ |
| Home (legacy) | `home/.../home_page.dart` | ❌ | ✅ |

### 1.3 Calculator
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Calculator input | `calculator/views/calculator_input_screen.dart` | ✅ | ✅ |
| Devis request | `calculator/screens/devis_request_screen.dart` | ✅ | ✅ |
| Calculator result | `calculator/screens/calculator_result_screen.dart` | ✅ | ✅ |
| Result ON-GRID | `calculator/screens/result_on_grid_screen.dart` | ✅ | ✅ |
| Result OFF-GRID | `calculator/screens/result_off_grid_screen.dart` | ✅ | ✅ |
| Result HYBRID | `calculator/screens/result_hybrid_screen.dart` | ✅ | ✅ |
| Result Pumping | `calculator/screens/result_pumping_screen.dart` | ✅ | ✅ |

### 1.4 Project study (Étude de projet)
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Project type choice | `project_study/.../project_type_screen.dart` | ✅ | ✅ |
| Project form (generic) | `project_study/.../project_form_screen.dart` | ✅ | ✅ |
| ON-GRID form | `project_study/.../on_grid_form_screen.dart` | ✅ | ✅ |
| OFF-GRID form | `project_study/.../off_grid_form_screen.dart` | ✅ | ✅ |
| HYBRID form | `project_study/.../hybrid_form_screen.dart` | ✅ | ✅ |
| PUMPING form | `project_study/.../pumping_form_screen.dart` | ✅ | ✅ |
| Project study (alt) | `project_study/.../project_study_page.dart` | ✅ | ✅ |

### 1.5 Étude / Devis
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Étude devis | `etude_devis/.../etude_devis_screen.dart` | ✅ | ✅ |

### 1.6 Espace Pro (Partners & Technicians)
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Espace Pro home | `espace_pro/.../espace_pro_screen.dart` | ✅ | ✅ |
| Partner registration | `espace_pro/.../partner_registration_screen.dart` | ✅ | ✅ |
| Technician registration | `espace_pro/.../technician_registration_screen.dart` | ✅ | ✅ |

### 1.7 Partners & Technicians (lists)
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Partners list | `partners/.../partners_list_screen.dart` | ✅ | ✅ |
| Technicians list | `technicians/.../technicians_list_screen.dart` | ✅ | ✅ |

### 1.8 Search
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Search choice | `search/.../search_choice_screen.dart` | ✅ | ✅ |
| Technicians search | `search/.../technicians_search_screen.dart` | ✅ | ✅ |
| Companies search | `search/.../companies_search_screen.dart` | ✅ | ✅ |

### 1.9 Profile
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Profile | `profile/screens/profile_screen.dart` | ✅ | ✅ |

### 1.10 Pumping
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Pumping input | `pumping/screens/pumping_input_screen.dart` | ✅ | ✅ |
| Pumping result | `pumping/screens/pumping_result_screen.dart` | ✅ | ✅ |
| Pumping devis form | `pumping/screens/pumping_devis_form_screen.dart` | ✅ | ✅ |

### 1.11 Installation & Maintenance
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Installation / Maintenance choice | `installation/.../installation_maintenance_choice_screen.dart` | ❌ | ✅ |
| Installation request | `installation/.../installation_request_screen.dart` | ✅ | ✅ |
| Maintenance request | `installation/.../maintenance_request_screen.dart` | ✅ | ✅ |

### 1.12 Marketplace
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Marketplace | `marketplace/screens/marketplace_screen.dart` | ✅ | ✅ |
| Product details | `marketplace/screens/product_details_screen.dart` | ❌ | ✅ |

### 1.13 Quote
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Quote request | `quote/screens/quote_request_screen.dart` | ❌ | ✅ |

### 1.14 Financing
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Financing form | `financing/.../financing_form_screen.dart` | ❌ | ✅ |

### 1.15 Intervention
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Intervention choice | `intervention/.../intervention_choice_screen.dart` | ❌ | ✅ |

### 1.16 Admin (in-app)
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Admin dashboard | `admin/screens/admin_dashboard_screen.dart` | ❌ | ❌ |
| Admin home dashboard | `admin/screens/admin_home_dashboard_screen.dart` | ❌ | ❌ |
| Admin devis list | `admin/screens/admin_devis_list_screen.dart` | ❌ | ❌ |
| Admin applications list | `admin/screens/admin_applications_list_screen.dart` | ❌ | ❌ |
| Admin technicians list | `admin/screens/admin_technicians_list_screen.dart` | ❌ | ❌ |
| Admin partners list | `admin/screens/admin_partners_list_screen.dart` | ❌ | ❌ |
| Admin pumping list | `admin/screens/admin_pumping_list_screen.dart` | ❌ | ❌ |
| Admin installation list | `admin/screens/admin_installation_list_screen.dart` | ❌ | ❌ |
| Admin maintenance list | `admin/screens/admin_maintenance_list_screen.dart` | ❌ | ❌ |
| Admin notifications | `admin/screens/admin_notifications_screen.dart` | ❌ | ❌ |

### 1.17 Admin Web (admin_v2)
| Page | Path | Arabic | Dark mode |
|------|------|--------|-----------|
| Dashboard | `admin_v2/pages/dashboard_page.dart` | ❌ | ⚠️ (theme in app) |
| Partners | `admin_v2/pages/partners_page.dart` | ❌ | ⚠️ |
| Technicians | `admin_v2/pages/technicians_page.dart` | ❌ | ⚠️ |
| Technician applications | `admin_v2/pages/technician_applications_page.dart` | ❌ | ⚠️ |
| Partner applications | `admin_v2/pages/partner_applications_page.dart` | ❌ | ⚠️ |
| Project | `admin_v2/pages/project_page.dart` | ❌ | ⚠️ |
| Pumping | `admin_v2/pages/pumping_page.dart` | ❌ | ⚠️ |
| Installation | `admin_v2/pages/installation_page.dart` | ❌ | ⚠️ |
| Maintenance | `admin_v2/pages/maintenance_page.dart` | ❌ | ⚠️ |
| Devis | `admin_v2/pages/devis_page.dart` | ❌ | ⚠️ |
| Notifications | `admin_v2/pages/notifications_page.dart` | ❌ | ⚠️ |

---

## 2. Reusable components (widgets)

### 2.1 Core widgets (`lib/core/widgets/`)
| Component | Path | Arabic | Dark mode |
|-----------|------|--------|-----------|
| Success dialog | `core/widgets/success_dialog.dart` | ✅ | ✅ |
| Offline overlay | `core/widgets/offline_overlay.dart` | ✅ | ✅ |
| Skeleton loading | `core/widgets/skeleton_loading.dart` | ❌ | ✅ |
| Empty state | `core/widgets/empty_state_widget.dart` | ❌ | ✅ |
| App text field | `core/widgets/app_text_field.dart` | ❌ | ✅ |
| App button | `core/widgets/app_button.dart` | ❌ | ✅ |

### 2.2 Feature widgets
| Component | Path | Arabic | Dark mode |
|-----------|------|--------|-----------|
| Result card (project study) | `project_study/widgets/result_card.dart` | ❌ | ✅ |
| Home devis form dialog | `home/widgets/home_devis_form_dialog.dart` | ✅ | ✅ |

### 2.3 Admin widgets
| Component | Path | Arabic | Dark mode |
|-----------|------|--------|-----------|
| Admin stat card | `admin/widgets/admin_stat_card.dart` | ❌ | ❌ |
| Admin filter bar | `admin/widgets/admin_filter_bar.dart` | ❌ | ❌ |
| Admin chart card | `admin/widgets/admin_chart_card.dart` | ❌ | ❌ |
| Admin latest items card | `admin/widgets/admin_latest_items_card.dart` | ❌ | ❌ |
| Admin shared widgets | `admin/widgets/admin_shared_widgets.dart` | ❌ | ❌ |
| Technician assignment sheet | `admin/widgets/technician_assignment_sheet.dart` | ❌ | ❌ |
| Simple pie chart | `admin/widgets/simple_pie_chart.dart` | ❌ | ❌ |
| Simple bar chart | `admin/widgets/simple_bar_chart.dart` | ❌ | ❌ |
| Request detail dialog | `admin_v2/widgets/request_detail_dialog.dart` | ❌ | ❌ |
| Export bar | `admin_v2/widgets/export_bar.dart` | ❌ | ❌ |
| Advanced filters panel | `admin_v2/widgets/advanced_filters_panel.dart` | ❌ | ✅ |
| Simple data table | `admin_v2/widgets/simple_data_table.dart` | ❌ | ❌ |
| Admin web topbar | `admin_web/widgets/admin_web_topbar.dart` | ❌ | ❌ |
| Admin web sidebar | `admin_web/widgets/admin_web_sidebar.dart` | ❌ | ❌ |

---

## 3. Theme & l10n (app-wide)

| Item | Path | Notes |
|------|------|--------|
| App theme (light + dark) | `core/theme/app_theme.dart` | Dark theme defined; app uses system brightness |
| App colors | `core/constants/app_colors.dart` | Shared colors |
| Localizations (AR/EN/FR) | `l10n/app_ar.arb`, `app_en.arb`, `app_fr.arb` | Arabic present for all keys used by screens that call `AppLocalizations` |

---

## 4. Summary

| Category | Total | With Arabic | With dark mode |
|----------|--------|-------------|----------------|
| **Main app pages** (excl. admin_v2) | ~45 | ~35 | ~42 |
| **Admin (in-app + admin_v2)** | ~21 | 0 | ~1 (advanced_filters) |
| **Core + feature widgets** | 8 | 2 | 7 |
| **Admin widgets** | 14 | 0 | 1 |

**Completed (this pass):**
1. **Arabic (l10n):** Project study (project_type_screen, on_grid/off_grid/hybrid/pumping_form_screen, project_form_screen, project_study_page) now use `AppLocalizations` for titles, labels, and buttons. New keys added to `app_en.arb`, `app_fr.arb`, `app_ar.arb` (e.g. `projectStudyTitle`, `selectProjectType`, `pumpingStudyTitle`, `monthlyConsumptionKwh`, `requestQuoteButton`, etc.).
2. **Dark mode:** Calculator result screens (result_on_grid, result_off_grid, result_hybrid, result_pumping, calculator_result_screen) use `colorScheme`, `scaffoldBackgroundColor`, `surface`, `onSurface`, `surfaceContainerHighest`, `onSurfaceVariant`, theme shadows. Project study page and _TypeChip use theme. Core widgets: `empty_state_widget`, `app_text_field`, `app_button` use theme colors.

**Remaining (optional):**
- **Arabic:** installation_maintenance_choice, product_details_screen, quote_request_screen, financing_form_screen, intervention_choice_screen (add l10n keys and use in UI).
- **Dark mode:** Applied to espace_pro_screen, search screens (3), pumping input/result/devis screens, installation screens (choice, request, maintenance_request), marketplace_screen, product_details_screen, quote_request_screen, financing_form_screen, intervention_choice_screen, register_page, home_devis_form_dialog (all use colorScheme / scaffoldBackgroundColor).
