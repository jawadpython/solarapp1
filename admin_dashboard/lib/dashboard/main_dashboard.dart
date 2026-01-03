import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../layouts/admin_layout.dart';
import '../utils/app_theme.dart';
import '../requests/devis_requests_page.dart';
import '../requests/installation_requests_page.dart';
import '../requests/maintenance_requests_page.dart';
import '../requests/pumping_requests_page.dart';
import '../requests/project_requests_page.dart';
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
        return const ProjectRequestsPage();
      case 6:
        return const TechnicianApplicationsPage();
      case 7:
        return const PartnerApplicationsPage();
      case 8:
        return const TechniciansPage();
      case 9:
        return const PartnersPage();
      case 10:
        return const NotificationsPage();
      default:
        return _DashboardHome(statistics: _statistics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedIndex: _selectedIndex,
      onNavigationChanged: (index) {
        setState(() {
          _selectedIndex = index;
          if (index == 0) {
            _loadStatistics();
          }
        });
      },
      content: _getPage(),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final Map<String, int> statistics;

  const _DashboardHome({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tableau de bord',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vue d\'ensemble de votre activité',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Quick Actions
              if (isDesktop)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Exporter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 0,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      label: const Text('Filtrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 40),
          // Statistics Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 4;
              if (constraints.maxWidth < 1200) crossAxisCount = 3;
              if (constraints.maxWidth < 900) crossAxisCount = 2;
              if (constraints.maxWidth < 600) crossAxisCount = 1;
              
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isDesktop ? 1.4 : 1.5,
                children: [
                  _PremiumStatCard(
                    title: 'Devis',
                    value: statistics['devis']?.toString() ?? '0',
                    icon: Icons.request_quote_rounded,
                    color: AppTheme.primaryColor,
                    growth: '+12%',
                  ),
                  _PremiumStatCard(
                    title: 'Installation',
                    value: statistics['installation']?.toString() ?? '0',
                    icon: Icons.construction_rounded,
                    color: AppTheme.infoColor,
                    growth: '+8%',
                  ),
                  _PremiumStatCard(
                    title: 'Maintenance',
                    value: statistics['maintenance']?.toString() ?? '0',
                    icon: Icons.build_rounded,
                    color: AppTheme.warningColor,
                    growth: '+5%',
                  ),
                  _PremiumStatCard(
                    title: 'Pompage',
                    value: statistics['pumping']?.toString() ?? '0',
                    icon: Icons.water_drop_rounded,
                    color: AppTheme.secondaryColor,
                    growth: '+15%',
                  ),
                  _PremiumStatCard(
                    title: 'Candidatures Techniciens',
                    value: statistics['pendingTechnicianApps']?.toString() ?? '0',
                    icon: Icons.person_add_rounded,
                    color: AppTheme.successColor,
                    growth: null,
                    isPending: true,
                  ),
                  _PremiumStatCard(
                    title: 'Candidatures Partenaires',
                    value: statistics['pendingPartnerApps']?.toString() ?? '0',
                    icon: Icons.business_center_rounded,
                    color: AppTheme.infoColor,
                    growth: null,
                    isPending: true,
                  ),
                  _PremiumStatCard(
                    title: 'Techniciens Actifs',
                    value: statistics['technicians']?.toString() ?? '0',
                    icon: Icons.people_rounded,
                    color: AppTheme.successColor,
                    growth: '+3',
                  ),
                  _PremiumStatCard(
                    title: 'Partenaires Actifs',
                    value: statistics['partners']?.toString() ?? '0',
                    icon: Icons.business_rounded,
                    color: AppTheme.primaryColor,
                    growth: '+2',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? growth;
  final bool isPending;

  const _PremiumStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.growth,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                if (growth != null && !isPending) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 14,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          growth!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'En attente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

