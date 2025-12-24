import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/widgets/app_button.dart';
import 'package:noor_energy/core/widgets/app_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Study'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Your Solar Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details below to get a personalized solar study',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            // Project Type
            Text(
              'Project Type',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Residential',
                    isSelected: _selectedType == 'Residential',
                    onTap: () => setState(() => _selectedType = 'Residential'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeChip(
                    label: 'Commercial',
                    isSelected: _selectedType == 'Commercial',
                    onTap: () => setState(() => _selectedType = 'Commercial'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Location',
              hint: 'Enter your city or address',
              controller: _locationController,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Monthly Consumption (kWh)',
              hint: 'Enter your average consumption',
              controller: _consumptionController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.bolt_outlined),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Generate Study',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Generated'),
        content: const Text(
          'Your solar project study has been created. Our team will contact you soon with detailed recommendations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

