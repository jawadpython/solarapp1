import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_analytics_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_stat_card.dart';
import 'package:noor_energy/features/admin/widgets/admin_chart_card.dart';
import 'package:noor_energy/features/admin/widgets/admin_latest_items_card.dart';

class AdminHomeDashboardScreen extends StatefulWidget {
  const AdminHomeDashboardScreen({super.key});

  @override
  State<AdminHomeDashboardScreen> createState() => _AdminHomeDashboardScreenState();
}

class _AdminHomeDashboardScreenState extends State<AdminHomeDashboardScreen> {
  final _analyticsService = AdminAnalyticsService();
  
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _latestRequests = [];
  List<Map<String, dynamic>> _latestTechApps = [];
  List<Map<String, dynamic>> _latestPartnerApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _analyticsService.getStatistics();
      final latestRequests = await _analyticsService.getLatestRequests(limit: 5);
      final latestTechApps = await _analyticsService.getLatestTechnicianApplications(limit: 5);
      final latestPartnerApps = await _analyticsService.getLatestPartnerApplications(limit: 5);
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _latestRequests = latestRequests;
          _latestTechApps = latestTechApps;
          _latestPartnerApps = latestPartnerApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is Timestamp) {
      final dt = date.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de bord',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vue d\'ensemble et statistiques',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Statistics Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                AdminStatCard(
                  title: 'Devis',
                  value: '${_stats['devisRequests'] ?? 0}',
                  icon: Icons.request_quote,
                  color: Colors.blue,
                ),
                AdminStatCard(
                  title: 'Installation',
                  value: '${_stats['installationRequests'] ?? 0}',
                  icon: Icons.solar_power,
                  color: Colors.orange,
                ),
                AdminStatCard(
                  title: 'Maintenance',
                  value: '${_stats['maintenanceRequests'] ?? 0}',
                  icon: Icons.build,
                  color: Colors.green,
                ),
                AdminStatCard(
                  title: 'Pompage',
                  value: '${_stats['pumpingRequests'] ?? 0}',
                  icon: Icons.water,
                  color: Colors.cyan,
                ),
                AdminStatCard(
                  title: 'Techniciens',
                  value: '${_stats['technicians'] ?? 0}',
                  icon: Icons.build_circle,
                  color: Colors.purple,
                ),
                AdminStatCard(
                  title: 'Partenaires',
                  value: '${_stats['partners'] ?? 0}',
                  icon: Icons.business,
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Status Overview Cards
            Row(
              children: [
                Expanded(
                  child: AdminStatCard(
                    title: 'En attente',
                    value: '${_stats['totalPending'] ?? 0}',
                    icon: Icons.pending,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminStatCard(
                    title: 'Approuvés',
                    value: '${_stats['totalApproved'] ?? 0}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminStatCard(
                    title: 'Rejetés',
                    value: '${_stats['totalRejected'] ?? 0}',
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Charts Row
            Row(
              children: [
                Expanded(
                  child: AdminChartCard(
                    title: 'Demandes par type',
                    chartType: 'pie',
                    analyticsService: _analyticsService,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminChartCard(
                    title: 'Approuvé vs Rejeté',
                    chartType: 'ratio',
                    analyticsService: _analyticsService,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Latest Requests
            AdminLatestItemsCard(
              title: 'Dernières demandes',
              items: _latestRequests,
              formatDate: _formatDate,
            ),
            const SizedBox(height: 16),
            
            // Latest Applications
            Row(
              children: [
                Expanded(
                  child: AdminLatestItemsCard(
                    title: 'Candidatures Techniciens',
                    items: _latestTechApps,
                    formatDate: _formatDate,
                    maxItems: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminLatestItemsCard(
                    title: 'Candidatures Partenaires',
                    items: _latestPartnerApps,
                    formatDate: _formatDate,
                    maxItems: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

