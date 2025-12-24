import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/project_study/widgets/result_card.dart';
import 'package:noor_energy/routes/app_routes.dart';

class HybridFormScreen extends StatefulWidget {
  const HybridFormScreen({super.key});

  @override
  State<HybridFormScreen> createState() => _HybridFormScreenState();
}

class _HybridFormScreenState extends State<HybridFormScreen> {
  // Default sun hours constant
  static const double _defaultSunHours = 5.5;

  final _formKey = GlobalKey<FormState>();
  final _dailyConsumptionController = TextEditingController();
  final _coverageController = TextEditingController(text: '70');
  final _blackoutHoursController = TextEditingController(text: '0');
  
  int _selectedPanelPower = 550;
  double _pvPower = 0;
  double _numberOfPanels = 0;
  double _batteryCapacity = 0;

  final List<int> _panelPowers = [400, 450, 500, 550, 600, 650];

  @override
  void dispose() {
    _dailyConsumptionController.dispose();
    _coverageController.dispose();
    _blackoutHoursController.dispose();
    super.dispose();
  }

  void _calculate() {
    final dailyConsumption = double.tryParse(_dailyConsumptionController.text) ?? 0;
    final coveragePercent = double.tryParse(_coverageController.text) ?? 70;

    // Safe division by zero check
    if (dailyConsumption > 0 && coveragePercent > 0 && coveragePercent <= 100 && 
        _defaultSunHours > 0 && _selectedPanelPower > 0) {
      // HYBRID Formula: SolarEnergy = dailyConsumption * (coveragePercent / 100)
      final solarEnergy = dailyConsumption * (coveragePercent / 100);
      
      // PvKw = SolarEnergy / SunHours
      _pvPower = solarEnergy / _defaultSunHours;
      
      // BatteryCapacity = SolarEnergy * 1.2
      _batteryCapacity = solarEnergy * 1.2;
      
      // Panels = (PvKw * 1000) / panelWp
      _numberOfPanels = (_pvPower * 1000) / _selectedPanelPower;
      
      setState(() {});
    } else {
      setState(() {
        _pvPower = 0;
        _numberOfPanels = 0;
        _batteryCapacity = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('HYBRID - Étude de projet'),
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
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.solar_power, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'HYBRID',
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

              // Daily Consumption
              const Text(
                'Consommation quotidienne (kWh)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dailyConsumptionController,
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
                  hintText: 'Ex: 15',
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

              // Solar Coverage
              const Text(
                'Couverture solaire (%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coverageController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le pourcentage';
                  }
                  final percent = double.tryParse(value);
                  if (percent == null || percent <= 0 || percent > 100) {
                    return 'Veuillez entrer un pourcentage entre 1 et 100';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 70',
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

              // Blackout Hours (Optional)
              const Text(
                'Heures de coupure (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _blackoutHoursController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                decoration: InputDecoration(
                  hintText: 'Ex: 4 (heures par jour)',
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
              if (_pvPower > 0) ...[
                ResultCard(
                  projectType: 'HYBRID',
                  systemPower: _pvPower,
                  pvPower: _pvPower,
                  numberOfPanels: _numberOfPanels.ceil(),
                  batteryCapacity: _batteryCapacity,
                ),
                const SizedBox(height: 24),
                
                // Quote Request Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _pvPower > 0
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.quoteRequest,
                              arguments: {
                                'systemType': 'HYBRID',
                                'panels': _numberOfPanels.ceil(),
                                'systemPower': _pvPower,
                                'batteryCapacity': _batteryCapacity,
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
                      backgroundColor: const Color(0xFF2196F3),
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

