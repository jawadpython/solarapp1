import 'package:flutter/material.dart';
import '../widgets/modern_sidebar.dart';
import '../widgets/modern_topbar.dart';

/// Production-Ready Admin Layout for Flutter Web
/// - Single Scaffold with fixed sidebar
/// - Content area properly constrained for Flutter Web
/// - No empty/gray areas - guaranteed rendering
class AdminLayout extends StatefulWidget {
  final Widget content;
  final int selectedIndex;
  final Function(int) onNavigationChanged;

  const AdminLayout({
    super.key,
    required this.content,
    required this.selectedIndex,
    required this.onNavigationChanged,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _sidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Responsive breakpoints
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1200;
  bool get _isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mobile: Use Drawer
    if (_isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),
        drawer: Drawer(
          child: ModernSidebar(
            selectedIndex: widget.selectedIndex,
            onItemSelected: (index) {
              widget.onNavigationChanged(index);
              Navigator.of(context).pop(); // Close drawer
            },
            isCollapsed: false,
          ),
        ),
        body: Column(
          children: [
            ModernTopBar(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      );
    }

    // Desktop & Tablet: Fixed sidebar layout
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Fixed Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: _isTablet && !_sidebarExpanded ? 80 : 260,
            child: ModernSidebar(
              selectedIndex: widget.selectedIndex,
              onItemSelected: widget.onNavigationChanged,
              isCollapsed: _isTablet && !_sidebarExpanded,
            ),
          ),
          // Main Content Area - CRITICAL: Must use Expanded
          Expanded(
            child: Column(
              children: [
                ModernTopBar(
                  onMenuTap: _isTablet ? _toggleSidebar : null,
                ),
                // CRITICAL: Expanded ensures content fills available space
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build content with proper constraints for Flutter Web
  /// CRITICAL: Content must fill available space to prevent gray areas
  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      // CRITICAL: Use SizedBox.expand to ensure content fills available space
      // This prevents gray/empty areas on Flutter Web
      child: SizedBox.expand(
        key: ValueKey<int>(widget.selectedIndex),
        child: widget.content,
      ),
    );
  }
}
