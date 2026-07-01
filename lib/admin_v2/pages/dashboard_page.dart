import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

/// Dashboard Page with Statistics
/// 
/// CRITICAL: Must fill available space to prevent gray areas
/// Uses LayoutBuilder to get constraints and Column with mainAxisSize.max
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _firestoreService = AdminFirestoreService();
  Map<String, int> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _firestoreService.getStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statistics = {
            'devis': 0, 'installation': 0, 'maintenance': 0, 'pumping': 0,
            'project': 0, 'pendingTechnicianApps': 0, 'pendingPartnerApps': 0,
            'technicians': 0, 'partners': 0,
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Use LayoutBuilder to get available constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Page Header
              const Text(
                'Tableau de bord',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isLoading
                          ? 'Chargement...'
                          : (_statistics.values.every((v) => v == 0)
                              ? 'Vue d\'ensemble — Aucune donnée pour le moment'
                              : 'Vue d\'ensemble de votre activité'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadStatistics,
                      tooltip: 'Actualiser',
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Statistics Cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        crossAxisCount: constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            title: 'Devis',
                            value: _statistics['devis']?.toString() ?? '0',
                            icon: Icons.request_quote_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          _StatCard(
                            title: 'Installation',
                            value: _statistics['installation']?.toString() ?? '0',
                            icon: Icons.construction_rounded,
                            color: AppTheme.infoColor,
                          ),
                          _StatCard(
                            title: 'Maintenance',
                            value: _statistics['maintenance']?.toString() ?? '0',
                            icon: Icons.build_rounded,
                            color: AppTheme.warningColor,
                          ),
                          _StatCard(
                            title: 'Pompage',
                            value: _statistics['pumping']?.toString() ?? '0',
                            icon: Icons.water_drop_rounded,
                            color: AppTheme.secondaryColor,
                          ),
                          _StatCard(
                            title: 'Candidatures Techniciens',
                            value: _statistics['pendingTechnicianApps']?.toString() ?? '0',
                            icon: Icons.person_add_rounded,
                            color: AppTheme.successColor,
                            isPending: true,
                          ),
                          _StatCard(
                            title: 'Candidatures Partenaires',
                            value: _statistics['pendingPartnerApps']?.toString() ?? '0',
                            icon: Icons.business_center_rounded,
                            color: AppTheme.infoColor,
                            isPending: true,
                          ),
                          _StatCard(
                            title: 'Techniciens Actifs',
                            value: _statistics['technicians']?.toString() ?? '0',
                            icon: Icons.people_rounded,
                            color: AppTheme.successColor,
                          ),
                          _StatCard(
                            title: 'Partenaires Actifs',
                            value: _statistics['partners']?.toString() ?? '0',
                            icon: Icons.business_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPending;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
