import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/widgets/app_button.dart';
import 'package:noor_energy/core/widgets/app_text_field.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class ProjectStudyPage extends StatefulWidget {
  const ProjectStudyPage({super.key});

  @override
  State<ProjectStudyPage> createState() => _ProjectStudyPageState();
}

class _ProjectStudyPageState extends State<ProjectStudyPage> {
  final _locationController = TextEditingController();
  final _consumptionController = TextEditingController();
  String _selectedType = 'Residential';

  @override
  void dispose() {
    _locationController.dispose();
    _consumptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.projectStudyTitle),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.startSolarJourney,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.fillDetailsForStudy,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              loc.projectTypeLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: loc.residential,
                    isSelected: _selectedType == 'Residential',
                    onTap: () => setState(() => _selectedType = 'Residential'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeChip(
                    label: loc.commercial,
                    isSelected: _selectedType == 'Commercial',
                    onTap: () => setState(() => _selectedType = 'Commercial'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: loc.addressLabel,
              hint: loc.enterCityOrAddressHint,
              controller: _locationController,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: loc.monthlyConsumptionKwh,
              hint: loc.enterYourConsumption,
              controller: _consumptionController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.bolt_outlined),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: loc.getStudy,
                onPressed: () {
                  _showResultDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.success),
        content: Text(loc.requestSentSuccess),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

