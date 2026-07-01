import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/app_theme.dart';

/// Sidebar Navigation Widget
/// 
/// Complete sidebar with all menu items matching old admin
/// Changes pages via callback (no Navigator)
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'TAWFIR ',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'ENERGY',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _MenuItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(0),
                ),
                const SizedBox(height: 8),
                _SectionHeader(title: 'DEMANDES'),
                _MenuItem(
                  icon: Icons.request_quote_rounded,
                  label: 'Devis',
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(1),
                ),
                _MenuItem(
                  icon: Icons.construction_rounded,
                  label: 'Installation',
                  index: 2,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(2),
                ),
                _MenuItem(
                  icon: Icons.build_rounded,
                  label: 'Maintenance',
                  index: 3,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(3),
                ),
                _MenuItem(
                  icon: Icons.assignment,
                  label: 'Études & Projets',
                  index: 4,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(4),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'CANDIDATURES'),
                _MenuItem(
                  icon: Icons.person_add_rounded,
                  label: 'Techniciens',
                  index: 5,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(5),
                ),
                _MenuItem(
                  icon: Icons.business_center_rounded,
                  label: 'Partenaires',
                  index: 6,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(6),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'GESTION'),
                _MenuItem(
                  icon: Icons.people_rounded,
                  label: 'Techniciens',
                  index: 7,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(7),
                ),
                _MenuItem(
                  icon: Icons.business_rounded,
                  label: 'Partenaires',
                  index: 8,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(8),
                ),
                _MenuItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  index: 9,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(9),
                ),
                _MenuItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Produits',
                  index: 10,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(10),
                ),
                _MenuItem(
                  icon: Icons.chat_rounded,
                  label: 'Messages',
                  index: 11,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(11),
                ),
              ],
            ),
          ),
          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur de déconnexion: $e')),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Individual Menu Item Widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
