import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class ResultOffGridScreen extends StatefulWidget {
  final OffGridResult result;

  const ResultOffGridScreen({super.key, required this.result});

  @override
  State<ResultOffGridScreen> createState() => _ResultOffGridScreenState();
}

class _ResultOffGridScreenState extends State<ResultOffGridScreen> {
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

  /// Calculate environmental impact for OFF-GRID
  /// Off-grid saves 100% of E_day
  Map<String, double> _calculateEnvironmentalImpact(
    double kwhDay,
  ) {
    // Off-grid saves 100% of E_day
    // Formula: kWh_saved/an = E_day × 365
    final kwhSavedYear = kwhDay * 365;

    // Formula: CO2_kg/an = kWh_saved/an × 0.6
    const co2Factor = 0.6; // kg CO2 / kWh
    final co2Kg = kwhSavedYear * co2Factor;
    // Formula: CO2_ton/an = CO2_kg/an / 1000
    final co2Tonnes = co2Kg / 1000;

    // Formula: trees/an = CO2_kg/an / 22
    const kgPerTree = 22.0; // kg CO2 / tree / year
    final trees = co2Kg / kgPerTree;

    // Debug logs
    debugPrint("ENV INPUTS -> E_day: $kwhDay kWh");
    debugPrint("ENV OUTPUTS -> kwh_saved_year: $kwhSavedYear, CO2(t): $co2Tonnes, trees: $trees");

    return {
      'co2Tonnes': co2Tonnes,
      'arbres': trees,
    };
  }

  /// Build Environmental Impact Card
  Widget _buildEnvironmentalImpactCard(
    double kwhDay,
  ) {
    final impact = _calculateEnvironmentalImpact(kwhDay);
    final co2Tonnes = impact['co2Tonnes']!;
    final arbres = impact['arbres']!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.environmentalImpact,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.co2AvoidedTonPerYear(co2Tonnes.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.equivalentTreesPerYear(arbres.round()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.environmentalEstimationNote,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resultOffGrid),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.solar_power,
                          color: AppColors.primary,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ResultItem(
                    icon: Icons.home,
                    label: AppLocalizations.of(context)!.selectedProfile,
                    value: '${result.profile} (${result.kwhDay.toStringAsFixed(1)} kWh/day)',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context)!.autonomyLabel,
                    value: '${result.autonomyDays} ${result.autonomyDays == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days}',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.power,
                    label: AppLocalizations.of(context)!.pvRequiredKw,
                    value: '${result.pvPowerKW.toStringAsFixed(1)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.numberOfPanelsN,
                    value: '${result.panels}',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.battery_charging_full,
                    label: AppLocalizations.of(context)!.pvkwc,
                    value: '${result.pvKwc.toStringAsFixed(1)} kWc',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.battery_full,
                    label: AppLocalizations.of(context)!.batteryCapacityKwh,
                    value: '${result.batteryKwh.toStringAsFixed(1)} kWh',
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.electric_bolt,
                    label: AppLocalizations.of(context)!.inverterRecommendedKw,
                    value: '${result.inverterKW.toStringAsFixed(0)} kW',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  if (result.voltage != null) ...[
                    Row(
                      children: [
                        Icon(Icons.power_input, color: Colors.indigo),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.voltage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result.voltage!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (result.recommendedVoltage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.recommended(result.recommendedVoltage!),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.showVoltageWarning) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.voltageWarning,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Environmental Impact Card
            _buildEnvironmentalImpactCard(result.kwhDay),
            const SizedBox(height: 20),
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.basedOnSunHoursInfo(
                        result.sunHours.toStringAsFixed(1),
                        _regionName ?? result.regionCode,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Disclaimer
            Text(
              AppLocalizations.of(context)!.estimatedResults,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            // Request Devis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.request_quote, size: 24),
                label: Text(
                  AppLocalizations.of(context)!.requestDevis,
                  style: const TextStyle(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
                    color: Colors.grey.shade600,
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

