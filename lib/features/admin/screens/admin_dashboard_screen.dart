import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/user_state_service.dart';
import 'package:noor_energy/features/admin/screens/admin_applications_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_devis_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_home_dashboard_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_installation_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_maintenance_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_partners_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_pumping_list_screen.dart';
import 'package:noor_energy/features/admin/screens/admin_technicians_list_screen.dart';
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
    if (!UserStateService.instance.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreen);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Vue d\'ensemble'),
            Tab(icon: Icon(Icons.request_quote), text: 'Devis'),
            Tab(icon: Icon(Icons.solar_power), text: 'Installation'),
            Tab(icon: Icon(Icons.build), text: 'Maintenance'),
            Tab(icon: Icon(Icons.water), text: 'Pompage'),
            Tab(icon: Icon(Icons.build_circle), text: 'Techniciens'),
            Tab(icon: Icon(Icons.business), text: 'Partenaires'),
            Tab(icon: Icon(Icons.person_add), text: 'Candidatures'),
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

