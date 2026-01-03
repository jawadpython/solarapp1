import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/solar_result.dart';
import 'package:noor_energy/features/calculator/screens/devis_request_screen.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class CalculatorResultScreen extends StatefulWidget {
  final SolarResult result;
  final String systemType;

  const CalculatorResultScreen({
    super.key,
    required this.result,
    required this.systemType,
  });

  @override
  State<CalculatorResultScreen> createState() => _CalculatorResultScreenState();
}

class _CalculatorResultScreenState extends State<CalculatorResultScreen> {
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
    final savingRatePercent = (result.savingRate * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculationResult),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                          Icons.solar_power,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.calculationResults,
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
                  // Consommation estimée
                  _ResultItem(
                    icon: Icons.bolt,
                    label: AppLocalizations.of(context)!.estimatedConsumption,
                    value: '${result.kwhMonth.toStringAsFixed(1)} kWh / ${AppLocalizations.of(context)!.monthly.toLowerCase()}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  // Puissance système recommandée
                  _ResultItem(
                    icon: Icons.power,
                    label: AppLocalizations.of(context)!.recommendedSystemPower,
                    value: '${result.powerKW.toStringAsFixed(2)} kW',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  // Nombre de panneaux
                  _ResultItem(
                    icon: Icons.grid_view,
                    label: AppLocalizations.of(context)!.numberOfPanels,
                    value: '${result.panels}',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  // Taux d'économie
                  _ResultItem(
                    icon: Icons.percent,
                    label: AppLocalizations.of(context)!.savingRate,
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
                    color: Colors.black.withOpacity(0.05),
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
                          color: Colors.green.withOpacity(0.1),
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
                          AppLocalizations.of(context)!.savings,
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
                    label: AppLocalizations.of(context)!.monthly,
                    value: '${result.savingMonth.toStringAsFixed(2)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.yearly,
                    value: '${result.savingYear.toStringAsFixed(2)} DH',
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.tenYears,
                    value: '${result.saving10Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                  const SizedBox(height: 12),
                  _SavingsRow(
                    label: AppLocalizations.of(context)!.twentyYears,
                    value: '${result.saving20Y.toStringAsFixed(2)} DH',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
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
                      AppLocalizations.of(context)!.basedOnSunHours(result.monthName, _regionName ?? result.regionCode),
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
            // Footer Text
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
            // Demander un Devis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevisRequestScreen(
                        result: result,
                        systemType: widget.systemType,
                      ),
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

