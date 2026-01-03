import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';

/// Modern Sidebar with premium design
/// Supports collapsed state for tablet view
class ModernSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;

  const ModernSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(2, 0),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(1, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: EdgeInsets.all(isCollapsed ? 16 : 24),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
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
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tawfir Energy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(0),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 8),
                _SectionHeader(title: 'Demandes', isCollapsed: isCollapsed),
                _SidebarItem(
                  icon: Icons.request_quote_rounded,
                  title: 'Devis',
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(1),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.construction_rounded,
                  title: 'Installation',
                  index: 2,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(2),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.build_rounded,
                  title: 'Maintenance',
                  index: 3,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(3),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.water_drop_rounded,
                  title: 'Pompage',
                  index: 4,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(4),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.assignment,
                  title: 'Études & Projets',
                  index: 5,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(5),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Candidatures', isCollapsed: isCollapsed),
                _SidebarItem(
                  icon: Icons.person_add_rounded,
                  title: 'Techniciens',
                  index: 6,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(6),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.business_center_rounded,
                  title: 'Partenaires',
                  index: 7,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(7),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Gestion', isCollapsed: isCollapsed),
                _SidebarItem(
                  icon: Icons.people_rounded,
                  title: 'Techniciens',
                  index: 8,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(8),
                  isCollapsed: isCollapsed,
                ),
                _SidebarItem(
                  icon: Icons.business_rounded,
                  title: 'Partenaires',
                  index: 9,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(9),
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 16),
                _SidebarItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  index: 10,
                  selectedIndex: selectedIndex,
                  onTap: () => onItemSelected(10),
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: _LogoutButton(isCollapsed: isCollapsed),
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
  final bool isCollapsed;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: 22,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;

  const _SectionHeader({
    required this.title,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary.withOpacity(0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isCollapsed;

  const _LogoutButton({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.errorColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

