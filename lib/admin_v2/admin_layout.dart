import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'topbar.dart';
import 'pages/dashboard_page.dart';
import 'pages/devis_page.dart';
import 'pages/installation_page.dart';
import 'pages/maintenance_page.dart';
import 'pages/project_page.dart';
import 'pages/technician_applications_page.dart';
import 'pages/partner_applications_page.dart';
import 'pages/technicians_page.dart';
import 'pages/partners_page.dart';
import 'pages/notifications_page.dart';
import 'pages/products_page.dart';
import 'pages/chats_page.dart';

/// Clean Admin Layout V2 - Built for Flutter Web
/// 
/// CRITICAL DESIGN PRINCIPLES:
/// - Single Scaffold (ONE and ONLY ONE)
/// - Row layout: Sidebar (fixed) + Expanded (content)
/// - All pages must fill available space
/// - No nested Scaffolds
/// - No Navigator.push
/// - State-based page switching
class AdminLayoutV2 extends StatefulWidget {
  const AdminLayoutV2({super.key});

  @override
  State<AdminLayoutV2> createState() => _AdminLayoutV2State();
}

class _AdminLayoutV2State extends State<AdminLayoutV2> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Get the current page widget based on selected index
  /// CRITICAL: Each page must be a StatelessWidget that fills space
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage(key: ValueKey('dashboard'));
      case 1:
        return const DevisPage(key: ValueKey('devis'));
      case 2:
        return const InstallationPage(key: ValueKey('installation'));
      case 3:
        return const MaintenancePage(key: ValueKey('maintenance'));
      case 4:
        return const ProjectPage(key: ValueKey('project'));
      case 5:
        return const TechnicianApplicationsPage(key: ValueKey('tech_apps'));
      case 6:
        return const PartnerApplicationsPage(key: ValueKey('partner_apps'));
      case 7:
        return const TechniciansPage(key: ValueKey('technicians'));
      case 8:
        return const PartnersPage(key: ValueKey('partners'));
      case 9:
        return const NotificationsPage(key: ValueKey('notifications'));
      case 10:
        return const ProductsPage(key: ValueKey('products'));
      case 11:
        return const ChatsPage(key: ValueKey('chats'));
      default:
        return const DashboardPage(key: ValueKey('dashboard_default'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // SINGLE SCAFFOLD - This is the ONLY Scaffold in the entire admin
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Fixed Sidebar on the left
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
          // Main Content Area - MUST use Expanded
          Expanded(
            child: Column(
              children: [
                // Top Bar
                const TopBar(),
                // Page Content - CRITICAL: Expanded ensures content fills space
                Expanded(
                  child: Container(
                    color: Colors.white,
                    // CRITICAL: Use SizedBox.expand to ensure content fills space
                    // This prevents gray/empty areas on Flutter Web
                    child: SizedBox.expand(
                      child: _getCurrentPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
