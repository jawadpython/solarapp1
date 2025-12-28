import 'package:flutter/material.dart';
import 'package:noor_energy/admin_web/routes/admin_web_routes.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

/// Admin Web Sidebar - Navigation sidebar for web admin dashboard
class AdminWebSidebar extends StatelessWidget {
  const AdminWebSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Vue d\'ensemble',
                  route: AdminWebRoutes.dashboard,
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  context,
                  icon: Icons.request_quote,
                  title: 'Demandes Devis',
                  route: AdminWebRoutes.devisRequests,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.solar_power,
                  title: 'Demandes Installation',
                  route: AdminWebRoutes.installationRequests,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.build,
                  title: 'Demandes Maintenance',
                  route: AdminWebRoutes.maintenanceRequests,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.water_drop,
                  title: 'Demandes Pompage',
                  route: AdminWebRoutes.pumpingRequests,
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  context,
                  icon: Icons.build_circle,
                  title: 'Techniciens',
                  route: AdminWebRoutes.technicians,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.business,
                  title: 'Partenaires',
                  route: AdminWebRoutes.partners,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_add,
                  title: 'Candidatures',
                  route: AdminWebRoutes.applications,
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Paramètres',
                  route: AdminWebRoutes.settings,
                ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: TextButton.icon(
              onPressed: () {
                // TODO: Implement logout
                debugPrint('Logout');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      onTap: () {
        // TODO: Implement navigation for web
        debugPrint('Navigate to $route');
        Navigator.of(context).pop(); // Close drawer on mobile
      },
      hoverColor: AppColors.primary.withOpacity(0.1),
    );
  }
}
