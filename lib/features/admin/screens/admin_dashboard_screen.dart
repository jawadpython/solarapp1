import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/user_state_service.dart';
import 'package:noor_energy/features/admin/screens/admin_applications_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_devis_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_home_dashboard_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_installation_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_maintenance_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_notifications_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_partners_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_pumping_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_technicians_list_screen.dart';
import 'package:noor_energy/core/services/notification_service.dart';
import 'package:noor_energy/routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this); // Added Overview tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Security check: Only admins can access
    // TEMPORARILY DISABLED FOR TESTING - Boutique button navigation
    // if (!UserStateService.instance.isAdmin) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreen);
    //   });
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          _NotificationBell(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              // Refresh all tabs if needed
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Vue d\'ensemble'),
            Tab(icon: Icon(Icons.request_quote, size: 20), text: 'Devis'),
            Tab(icon: Icon(Icons.solar_power, size: 20), text: 'Installation'),
            Tab(icon: Icon(Icons.build, size: 20), text: 'Maintenance'),
            Tab(icon: Icon(Icons.water, size: 20), text: 'Pompage'),
            Tab(icon: Icon(Icons.build_circle, size: 20), text: 'Techniciens'),
            Tab(icon: Icon(Icons.business, size: 20), text: 'Partenaires'),
            Tab(icon: Icon(Icons.person_add, size: 20), text: 'Candidatures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminHomeDashboardScreen(),
          AdminDevisListScreen(),
          AdminInstallationListScreen(),
          AdminMaintenanceListScreen(),
          AdminPumpingListScreen(),
          AdminTechniciansListScreen(),
          AdminPartnersListScreen(),
          AdminApplicationsListScreen(),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final _notificationService = NotificationService();

  _NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _notificationService.getAdminNotificationsStream(),
      builder: (context, snapshot) {
        int unseenCount = 0;
        if (snapshot.hasData) {
          unseenCount = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['seen'] != true)
              .length;
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AdminNotificationsScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            if (unseenCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unseenCount > 99 ? '99+' : '$unseenCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

