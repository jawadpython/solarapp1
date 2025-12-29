import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../utils/app_theme.dart';
import '../requests/devis_requests_page.dart';
import '../requests/installation_requests_page.dart';
import '../requests/maintenance_requests_page.dart';
import '../requests/pumping_requests_page.dart';
import '../applications/technician_applications_page.dart';
import '../applications/partner_applications_page.dart';
import '../technicians/technicians_page.dart';
import '../partners/partners_page.dart';
import '../notifications/notifications_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final _firestoreService = AdminFirestoreService();
  int _selectedIndex = 0;
  Map<String, int> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _firestoreService.getStatistics();
    setState(() {
      _statistics = stats;
    });
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardHome(statistics: _statistics);
      case 1:
        return const DevisRequestsPage();
      case 2:
        return const InstallationRequestsPage();
      case 3:
        return const MaintenanceRequestsPage();
      case 4:
        return const PumpingRequestsPage();
      case 5:
        return const TechnicianApplicationsPage();
      case 6:
        return const PartnerApplicationsPage();
      case 7:
        return const TechniciansPage();
      case 8:
        return const PartnersPage();
      case 9:
        return const NotificationsPage();
      default:
        return _DashboardHome(statistics: _statistics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) {
                  _loadStatistics();
                }
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: _getPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final Map<String, int> statistics;

  const _DashboardHome({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Devis',
                value: statistics['devis']?.toString() ?? '0',
                icon: Icons.request_quote,
                color: AppTheme.primaryColor,
              ),
              _StatCard(
                title: 'Installation',
                value: statistics['installation']?.toString() ?? '0',
                icon: Icons.construction,
                color: AppTheme.infoColor,
              ),
              _StatCard(
                title: 'Maintenance',
                value: statistics['maintenance']?.toString() ?? '0',
                icon: Icons.build,
                color: AppTheme.warningColor,
              ),
              _StatCard(
                title: 'Pompage',
                value: statistics['pumping']?.toString() ?? '0',
                icon: Icons.water_drop,
                color: AppTheme.secondaryColor,
              ),
              _StatCard(
                title: 'Candidatures Techniciens',
                value: statistics['pendingTechnicianApps']?.toString() ?? '0',
                icon: Icons.person_add,
                color: AppTheme.successColor,
              ),
              _StatCard(
                title: 'Candidatures Partenaires',
                value: statistics['pendingPartnerApps']?.toString() ?? '0',
                icon: Icons.business_center,
                color: AppTheme.infoColor,
              ),
              _StatCard(
                title: 'Techniciens Actifs',
                value: statistics['technicians']?.toString() ?? '0',
                icon: Icons.people,
                color: AppTheme.successColor,
              ),
              _StatCard(
                title: 'Partenaires Actifs',
                value: statistics['partners']?.toString() ?? '0',
                icon: Icons.business,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

