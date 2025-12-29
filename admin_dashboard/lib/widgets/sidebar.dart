import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor, size: 32),
                SizedBox(width: 12),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(0),
                ),
                _SidebarItem(
                  icon: Icons.request_quote,
                  title: 'Devis',
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(1),
                ),
                _SidebarItem(
                  icon: Icons.construction,
                  title: 'Installation',
                  index: 2,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(2),
                ),
                _SidebarItem(
                  icon: Icons.build,
                  title: 'Maintenance',
                  index: 3,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(3),
                ),
                _SidebarItem(
                  icon: Icons.water_drop,
                  title: 'Pompage',
                  index: 4,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(4),
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: Icons.person_add,
                  title: 'Candidatures Techniciens',
                  index: 5,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(5),
                ),
                _SidebarItem(
                  icon: Icons.business_center,
                  title: 'Candidatures Partenaires',
                  index: 6,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(6),
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: Icons.people,
                  title: 'Techniciens',
                  index: 7,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(7),
                ),
                _SidebarItem(
                  icon: Icons.business,
                  title: 'Partenaires',
                  index: 8,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(8),
                ),
                const Divider(height: 32),
                _SidebarItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  index: 9,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(9),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

