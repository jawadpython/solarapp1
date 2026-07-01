import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:noor_energy/routes/app_routes.dart';

class ResultPumpingScreen extends StatefulWidget {
  final PumpingResult result;

  const ResultPumpingScreen({super.key, required this.result});

  @override
  State<ResultPumpingScreen> createState() => _ResultPumpingScreenState();
}

class _ResultPumpingScreenState extends State<ResultPumpingScreen> {
  String? _regionName;

  @override
  void initState() {
    super.initState();
    _loadRegionName();
  }

  Future<void> _loadRegionName() async {
    final regionName = await RegionService.instance
        .getRegionNameByCode(widget.result.regionCode);
    if (mounted) {
      setState(() {
        _regionName = regionName ?? widget.result.regionCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resultPumping),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Main Results Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.calculationResultsTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ResultItem(
                    icon: Icons.water_drop,
                    label: AppLocalizations.of(context)!.flowValue,
                    value: '${result.flowValue.toStringAsFixed(1)} ${result.flowUnit}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.height,
                    label: AppLocalizations.of(context)!.headMetersValue,
                    value: '${result.hmtMeters.toStringAsFixed(1)} m',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.power,
                    label: AppLocalizations.of(context)!.pumpPowerLabel,
                    value: '${result.pumpPowerKW.toStringAsFixed(2)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.solar_power,
                    label: AppLocalizations.of(context)!.pvPowerLabel,
                    value: '${result.pvPowerKW.toStringAsFixed(2)} kW',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.numberOfPanelsLabel,
                    value: '${result.panels}',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.settings,
                    label: AppLocalizations.of(context)!.pumpTypeValue,
                    value: result.pumpType,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Info Card
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final infoColor = isDark ? AppColors.infoOnDark : Colors.blue.shade700;
                final infoBg = isDark ? infoColor.withOpacity(0.15) : Colors.blue.withOpacity(0.08);
                final infoBorder = isDark ? infoColor.withOpacity(0.35) : Colors.blue.withOpacity(0.25);
                final infoText = isDark ? Theme.of(context).colorScheme.onSurface : Colors.blue.shade900;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: infoBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: infoBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: infoColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.basedOnSunHoursInfo(
                            result.sunHours.toStringAsFixed(1),
                            _regionName ?? result.regionCode,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: infoText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Disclaimer
            Text(
              AppLocalizations.of(context)!.estimatedResults,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            // Request Pumping Devis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.quoteRequest,
                    arguments: {
                      'systemType': result.systemType,
                      'panels': result.panels,
                      'systemPower': result.pvPowerKW,
                      'batteryCapacity': null,
                    },
                  );
                },
                icon: const Icon(Icons.request_quote, size: 24),
                label: Text(
                  AppLocalizations.of(context)!.requestPumpingQuote,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
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

