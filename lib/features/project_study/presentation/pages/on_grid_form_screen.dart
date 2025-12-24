import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/project_study/widgets/result_card.dart';
import 'package:noor_energy/routes/app_routes.dart';

class OnGridFormScreen extends StatefulWidget {
  const OnGridFormScreen({super.key});

  @override
  State<OnGridFormScreen> createState() => _OnGridFormScreenState();
}

class _OnGridFormScreenState extends State<OnGridFormScreen> {
  // Default sun hours constant
  static const double _defaultSunHours = 5.5;

  final _formKey = GlobalKey<FormState>();
  final _consumptionController = TextEditingController();
  final _sunHoursController = TextEditingController(text: _defaultSunHours.toString());
  
  int _selectedPanelPower = 550;
  double _systemPower = 0;
  double _numberOfPanels = 0;
  double _estimatedSavings = 0;

  final List<int> _panelPowers = [400, 450, 500, 550, 600, 650];

  @override
  void dispose() {
    _consumptionController.dispose();
    _sunHoursController.dispose();
    super.dispose();
  }

  void _calculate() {
    final monthlyConsumption = double.tryParse(_consumptionController.text) ?? 0;
    final sunHours = double.tryParse(_sunHoursController.text) ?? _defaultSunHours;

    // Safe division by zero check
    if (monthlyConsumption > 0 && sunHours > 0 && _selectedPanelPower > 0) {
      // ON-GRID Formula: SystemPowerKw = monthlyConsumption / (30 * SunHours)
      _systemPower = monthlyConsumption / (30 * sunHours);
      
      // Panels = (SystemPowerKw * 1000) / panelWp
      _numberOfPanels = (_systemPower * 1000) / _selectedPanelPower;
      
      // Estimate savings: system power × 12 hours × 1.2 DH/kWh × 365 days
      _estimatedSavings = _systemPower * 12 * 1.2 * 365;
      
      setState(() {});
    } else {
      setState(() {
        _systemPower = 0;
        _numberOfPanels = 0;
        _estimatedSavings = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ON-GRID - Étude de projet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.solar_power, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'ON-GRID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Monthly Consumption
              const Text(
                'Consommation mensuelle (kWh)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumptionController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la consommation';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 500',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Sun Hours
              const Text(
                'Heures d\'ensoleillement par jour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sunHoursController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les heures d\'ensoleillement';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 5.5',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Panel Power
              const Text(
                'Puissance du panneau (W)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedPanelPower,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _panelPowers.map((power) {
                      return DropdownMenuItem(
                        value: power,
                        child: Text('$power W'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPanelPower = value!);
                      _calculate();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Results Card
              if (_systemPower > 0) ...[
                ResultCard(
                  projectType: 'ON-GRID',
                  systemPower: _systemPower,
                  pvPower: _systemPower,
                  numberOfPanels: _numberOfPanels.ceil(),
                  batteryCapacity: 0,
                  estimatedSavings: _estimatedSavings,
                ),
                const SizedBox(height: 24),
                
                // Quote Request Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _systemPower > 0
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.quoteRequest,
                              arguments: {
                                'systemType': 'ON-GRID',
                                'panels': _numberOfPanels.ceil(),
                                'systemPower': _systemPower,
                                'batteryCapacity': null,
                              },
                            );
                          }
                        : null,
                    icon: const Icon(Icons.request_quote, size: 24),
                    label: const Text(
                      'Demander un devis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

