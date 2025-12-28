import 'package:flutter/material.dart';
import 'package:noor_energy/admin_web/widgets/admin_web_sidebar.dart';
import 'package:noor_energy/admin_web/widgets/admin_web_topbar.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

/// Admin Web Layout - Professional web dashboard layout
class AdminWebLayout extends StatelessWidget {
  final Widget content;
  final String? title;

  const AdminWebLayout({
    super.key,
    required this.content,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Row(
          children: [
            // Sidebar
            const AdminWebSidebar(),
            // Main content
            Expanded(
              child: Column(
                children: [
                  AdminWebTopBar(title: title),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        drawer: const AdminWebSidebar(),
        appBar: AppBar(
          title: Text(title ?? 'Admin Dashboard'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      );
    } else {
      // Mobile
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        drawer: const AdminWebSidebar(),
        appBar: AppBar(
          title: Text(title ?? 'Admin'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
        ),
        body: content,
      );
    }
  }
}
