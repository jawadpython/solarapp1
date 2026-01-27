import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class ResultOnGridScreen extends StatefulWidget {
  final OnGridResult result;

  const ResultOnGridScreen({super.key, required this.result});

  @override
  State<ResultOnGridScreen> createState() => _ResultOnGridScreenState();
}

class _ResultOnGridScreenState extends State<ResultOnGridScreen> {
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

  /// Calculate environmental impact with new constants
  Map<String, double> _calculateEnvironmentalImpact(
    double kWhMonth,
    double coveragePct,
  ) {
    // Step 11: kWh Saved
    // Formula: kwh_saved_month = E_month × (coverage_pct / 100)
    final kwhSavedMonth = kWhMonth * (coveragePct / 100);
    // Formula: kwh_saved_year = kwh_saved_month × 12
    final kwhSavedYear = kwhSavedMonth * 12;

    // Step 12: CO₂ avoided
    // Formula: co2_kg/year = kwh_saved_year × co2_factor
    const co2Factor = 0.6; // kg CO2 / kWh (updated from 0.7)
    final co2Kg = kwhSavedYear * co2Factor;
    // Formula: co2_ton/year = co2_kg/year / 1000
    final co2Tonnes = co2Kg / 1000;

    // Step 13: Trees equivalent
    // Formula: trees/year = co2_kg/year / kg_per_tree
    const kgPerTree = 22.0; // kg CO2 / tree / year (updated from 20)
    final trees = co2Kg / kgPerTree;

    // Debug logs
    debugPrint("ENV INPUTS -> kWhMonth: $kWhMonth, coverage: $coveragePct%");
    debugPrint("ENV OUTPUTS -> kwh_saved_year: $kwhSavedYear, CO2(t): $co2Tonnes, trees: $trees");

    return {
      'co2Tonnes': co2Tonnes,
      'arbres': trees,
    };
  }

  /// Build Environmental Impact Card
  Widget _buildEnvironmentalImpactCard(
    double kWhMonth,
    double coveragePct,
  ) {
    final impact = _calculateEnvironmentalImpact(kWhMonth, coveragePct);
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
                  AppLocalizations.of(context)!.co2AvoidedTonPerYear(co2Tonnes.toStringAsFixed(0)),
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
        title: Text(AppLocalizations.of(context)!.resultOnGrid),
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
                          style: const TextStyle(
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
                    icon: Icons.bolt,
                    label: AppLocalizations.of(context)!.emonth,
                    value: '${result.kwhMonth.toStringAsFixed(1)} kWh',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context)!.eday,
                    value: '${result.kwhDay.toStringAsFixed(1)} kWh',
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.solar_power,
                    label: AppLocalizations.of(context)!.ecovered,
                    value: '${result.kwhCovered.toStringAsFixed(1)} kWh',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.power,
                    label: AppLocalizations.of(context)!.pvpowerkw,
                    value: '${result.pvPowerKW.toStringAsFixed(1)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.numpanels,
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
                    icon: Icons.electric_bolt,
                    label: AppLocalizations.of(context)!.inverterkw,
                    value: '${result.inverterKW.toStringAsFixed(0)} kW',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.percent,
                    label: AppLocalizations.of(context)!.coverageLabel,
                    value: '${result.coveragePct.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.power_input, color: Colors.indigo),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.voltageLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.voltage,
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
            // Savings Card
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
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.savingsTitle,
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
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.savingMonth,
                    value: '${result.savingMonth.toStringAsFixed(0)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.billAfter,
                    value: '${result.billAfter.toStringAsFixed(0)} DH',
                    isHighlight: false,
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.yearlySavingsLabel,
                    value: '${result.savingYear.toStringAsFixed(2)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.tenYearsSavingsLabel,
                    value: '${result.saving10Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.twentyYearsSavingsLabel,
                    value: '${result.saving20Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Environmental Impact Card
            _buildEnvironmentalImpactCard(result.kwhMonth, result.coveragePct),
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
                  // Convert to old SolarResult format for compatibility
                  // TODO: Update DevisRequestScreen to accept new result types
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

class _SavingsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SavingsRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? Colors.green.shade200 : Colors.grey.shade300,
          width: isHighlight ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green.shade700 : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

