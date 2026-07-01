import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:noor_energy/routes/app_routes.dart';

class ResultHybridScreen extends StatefulWidget {
  final HybridResult result;

  const ResultHybridScreen({super.key, required this.result});

  @override
  State<ResultHybridScreen> createState() => _ResultHybridScreenState();
}

class _ResultHybridScreenState extends State<ResultHybridScreen> {
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

  /// Calculate environmental impact with new formulas
  Map<String, double> _calculateEnvironmentalImpact(
    double kWhMonth,
    double coveragePct,
  ) {
    // Step 8: Environmental Impact
    // Formula: kWh_saved/mois = E_mois × (Coverage / 100)
    final kwhSavedMonth = kWhMonth * (coveragePct / 100);
    // Formula: kWh_saved/an = kWh_saved/mois × 12
    final kwhSavedYear = kwhSavedMonth * 12;

    // Formula: CO2_kg/an = kWh_saved/an × 0.6
    const co2Factor = 0.6; // kg CO2 / kWh
    final co2Kg = kwhSavedYear * co2Factor;
    // Formula: CO2_ton/an = CO2_kg/an / 1000
    final co2Tonnes = co2Kg / 1000;

    // Formula: Arbres/an = CO2_kg/an / 22
    const kgPerTree = 22.0; // kg CO2 / tree / year
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

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final green = isDark ? AppColors.successOnDark : Colors.green;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: green.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.eco, color: green, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.environmentalImpact,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final green = isDark ? AppColors.successOnDark : Colors.green;
              final greenBg = isDark ? green.withOpacity(0.2) : Colors.green.withOpacity(0.08);
              final greenBorder = isDark ? green.withOpacity(0.4) : Colors.green.withOpacity(0.25);
              final greenText = isDark ? green : Colors.green.shade700;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greenBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.co2AvoidedTonPerYear(co2Tonnes.toStringAsFixed(1)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: greenText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.equivalentTreesPerYear(arbres.round()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: greenText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.environmentalEstimationNote,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
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
    // Build profile display text
    final loc = AppLocalizations.of(context)!;
    String profileText = '${result.profile} (${(result.dayRatio * 100).toStringAsFixed(0)}% ${loc.dayLabel} / ${(result.nightRatio * 100).toStringAsFixed(0)}% ${loc.nightLabel})';

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resultHybrid),
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ResultItem(
                    icon: Icons.bolt,
                    label: AppLocalizations.of(context)!.consumptionKwhMonth,
                    value: '${result.kwhMonth.toStringAsFixed(1)} kWh',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.home,
                    label: AppLocalizations.of(context)!.selectedProfileDayNight,
                    value: profileText,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.percent,
                    label: AppLocalizations.of(context)!.coverageLabel,
                    value: '${result.coveragePct.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.solar_power,
                    label: AppLocalizations.of(context)!.pvpowerkw,
                    value: '${result.pvPowerKW.toStringAsFixed(1)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.panelsN,
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
                    icon: Icons.battery_charging_full,
                    label: AppLocalizations.of(context)!.batteryCapacityKwh,
                    value: '${result.batteryKwh.toStringAsFixed(0)} kWh',
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.battery_full,
                    label: AppLocalizations.of(context)!.batteryUsable,
                    value: '${result.batteryUsable.toStringAsFixed(1)} kWh',
                    color: Colors.purpleAccent,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.nightlight,
                    label: AppLocalizations.of(context)!.nightCoveragePercent,
                    value: '${result.nightCoveragePct.toStringAsFixed(1)}%',
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.electric_bolt,
                    label: AppLocalizations.of(context)!.gridNightKwh,
                    value: '${result.kwhGridNight.toStringAsFixed(1)} kWh',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  _ResultItem(
                    icon: Icons.electric_bolt,
                    label: AppLocalizations.of(context)!.inverterRecommendedKw,
                    value: '${result.inverterKW.toStringAsFixed(0)} kW',
                    color: Colors.teal,
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
                              AppLocalizations.of(context)!.networkChosen,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
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
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final orange = isDark ? AppColors.warningOnDark : Colors.orange;
                        final orangeBg = isDark ? orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1);
                        final orangeBorder = isDark ? orange.withOpacity(0.4) : Colors.orange.withOpacity(0.4);
                        final orangeText = isDark ? Theme.of(context).colorScheme.onSurface : Colors.orange.shade900;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: orangeBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: orangeBorder, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.voltageWarning,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: orangeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (result.showRegulatoryWarning) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.regulatoryWarning,
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Savings Card
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.monthlySavingsLabel,
                    value: '${result.savingMonth.toStringAsFixed(0)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.billAfterLabel,
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
            // Request Devis Button
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
                      'batteryCapacity': result.batteryKwh,
                    },
                  );
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? AppColors.successOnDark : Colors.green;
    final greenMuted = isDark ? green.withOpacity(0.2) : Colors.green.withOpacity(0.12);
    final greenBorder = isDark ? green.withOpacity(0.4) : Colors.green.withOpacity(0.3);
    final greenText = isDark ? green : Colors.green.shade700;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? greenMuted : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? greenBorder : colorScheme.outline,
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
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlight ? greenText : green,
            ),
          ),
        ],
      ),
    );
  }
}

