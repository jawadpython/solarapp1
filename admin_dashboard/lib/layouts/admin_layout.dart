import 'package:flutter/material.dart';
import '../widgets/modern_sidebar.dart';
import '../widgets/modern_topbar.dart';

/// Responsive Admin Layout for Web Dashboard
/// - Desktop: Fixed sidebar (260px) + Topbar + Content
/// - Tablet: Collapsible sidebar + Topbar + Content
/// - Mobile: Drawer sidebar + Topbar + Content
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

  // Breakpoints for responsive design
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
        drawer: ModernSidebar(
          selectedIndex: widget.selectedIndex,
          onItemSelected: (index) {
            widget.onNavigationChanged(index);
            _scaffoldKey.currentState?.closeDrawer();
          },
          isCollapsed: false,
        ),
        body: Column(
          children: [
            ModernTopBar(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: widget.content),
          ],
        ),
      );
    }

    // Tablet & Desktop: Use Row layout
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Sidebar
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
          // Main content area
          Expanded(
            child: Column(
              children: [
                ModernTopBar(
                  onMenuTap: _isTablet ? _toggleSidebar : null,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(widget.selectedIndex),
                      child: widget.content,
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

