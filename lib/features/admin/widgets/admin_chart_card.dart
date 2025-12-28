import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_analytics_service.dart';
import 'package:noor_energy/features/admin/widgets/simple_pie_chart.dart';
import 'package:noor_energy/features/admin/widgets/simple_bar_chart.dart';

class AdminChartCard extends StatefulWidget {
  final String title;
  final String chartType; // 'pie', 'ratio', 'trend'
  final AdminAnalyticsService analyticsService;

  const AdminChartCard({
    super.key,
    required this.title,
    required this.chartType,
    required this.analyticsService,
  });

  @override
  State<AdminChartCard> createState() => _AdminChartCardState();
}

class _AdminChartCardState extends State<AdminChartCard> {
  Map<String, double> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);
    try {
      Map<String, double> data;
      if (widget.chartType == 'pie') {
        data = await widget.analyticsService.getRequestsPerType();
      } else if (widget.chartType == 'ratio') {
        data = await widget.analyticsService.getApprovedRejectedRatio();
      } else {
        data = await widget.analyticsService.getPumpingVsSolarShare();
      }
      
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_data.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'No data yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: widget.chartType == 'pie'
                  ? SimplePieChart(data: _data)
                  : SimpleBarChart(data: _data),
            ),
        ],
      ),
    );
  }
}

