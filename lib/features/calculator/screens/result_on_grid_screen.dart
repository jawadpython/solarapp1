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

  /// Calculate environmental impact
  Map<String, double> _calculateEnvironmentalImpact(
    double kWhMonth,
    double tauxEconomie,
    String systemType,
  ) {
    // A) Solar coverage
    // tauxEconomie is already a decimal (0.70 = 70%)
    double couverture;
    if (systemType == "ON-GRID" || systemType == "ON_GRID") {
      couverture = tauxEconomie.clamp(0.0, 0.9);
    } else if (systemType == "HYBRID") {
      couverture = tauxEconomie.clamp(0.0, 0.95);
    } else if (systemType == "OFF-GRID" || systemType == "OFF_GRID") {
      couverture = 1.0;
    } else {
      couverture = tauxEconomie.clamp(0.0, 0.9);
    }

    // B) Energy saved per year
    double kWhSavedYear = kWhMonth * 12 * couverture;

    // C) CO₂ saved
    const double EF = 0.7; // kg CO2 / kWh
    double co2Kg = kWhSavedYear * EF;
    double co2Tonnes = co2Kg / 1000;

    // D) Trees equivalent (1 tree ≈ 20 kg CO2 / year)
    double arbres = co2Kg / 20;

    // Debug logs
    debugPrint("ENV INPUTS -> kWhMonth: $kWhMonth, taux: $tauxEconomie, type: $systemType");
    debugPrint("ENV OUTPUTS -> CO2(t): $co2Tonnes, arbres: $arbres");

    return {
      'co2Tonnes': co2Tonnes,
      'arbres': arbres,
    };
  }

  /// Build Environmental Impact Card
  Widget _buildEnvironmentalImpactCard(
    double kWhMonth,
    double tauxEconomie,
    String systemType,
  ) {
    final impact = _calculateEnvironmentalImpact(kWhMonth, tauxEconomie, systemType);
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
                  AppLocalizations.of(context)!.co2Avoided(co2Tonnes.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.equivalentTrees(arbres.round()),
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
    final savingRatePercent = (result.savingRate * 100).toStringAsFixed(0);

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
                    label: AppLocalizations.of(context)!.estimatedConsumptionLabel,
                    value: '${result.kwhMonth.toStringAsFixed(1)} kWh / ${AppLocalizations.of(context)!.monthlyLabel.toLowerCase()}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.power,
                    label: AppLocalizations.of(context)!.recommendedSystemPowerLabel,
                    value: '${result.powerKW.toStringAsFixed(2)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.numberOfPanelsLabel,
                    value: '${result.panels}',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.percent,
                    label: AppLocalizations.of(context)!.savingRateLabel,
                    value: '$savingRatePercent%',
                    color: Colors.green,
                  ),
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
                    label: AppLocalizations.of(context)!.monthlyLabel,
                    value: '${result.savingMonth.toStringAsFixed(2)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.yearlyLabel,
                    value: '${result.savingYear.toStringAsFixed(2)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.tenYearsLabel,
                    value: '${result.saving10Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.twentyYearsLabel,
                    value: '${result.saving20Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Environmental Impact Card
            _buildEnvironmentalImpactCard(result.kwhMonth, result.savingRate, result.systemType),
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

