import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/project_study/utils/project_calculator.dart';
import 'package:noor_energy/features/project_study/widgets/result_card.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class ProjectFormScreen extends StatefulWidget {
  final String projectType;

  const ProjectFormScreen({super.key, required this.projectType});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _consumptionController = TextEditingController();
  
  bool _isKwh = true;
  int _selectedPanelPower = 550;
  double _estimatedPower = 0;
  double _numberOfPanels = 0;
  double _batteryCapacity = 0; // For OFF-GRID and HYBRID
  double _pvPower = 0;
  
  // Default sun hours for calculations
  static const double _defaultSunHours = 5.5;

  final List<int> _panelPowers = [400, 450, 500, 550, 600, 650, 700];

  @override
  void dispose() {
    _consumptionController.dispose();
    super.dispose();
  }

  /// Recalculates all values based on project type and inputs
  void _calculateEstimatedPower() {
    final consumption = double.tryParse(_consumptionController.text) ?? 0;
    
    if (consumption <= 0) {
      _estimatedPower = 0;
      _numberOfPanels = 0;
      _batteryCapacity = 0;
      _pvPower = 0;
      setState(() {});
      return;
    }

    switch (widget.projectType) {
      case 'ON-GRID':
        _calculateOnGrid(consumption);
        break;
      case 'OFF-GRID':
        _calculateOffGrid(consumption);
        break;
      case 'HYBRID':
        _calculateHybrid(consumption);
        break;
      case 'PUMPING':
        _calculatePumping(consumption);
        break;
      default:
        _estimatedPower = 0;
        _numberOfPanels = 0;
        _batteryCapacity = 0;
        _pvPower = 0;
    }
    
    setState(() {});
  }

  void _calculateOnGrid(double consumption) {
    if (_isKwh) {
      // Monthly consumption in kWh
      _estimatedPower = ProjectCalculator.onGridPower(consumption, sunHours: _defaultSunHours);
    } else {
      // Direct kW input
      _estimatedPower = consumption;
    }
    
    _pvPower = _estimatedPower;
    _numberOfPanels = ProjectCalculator.onGridPanels(_estimatedPower, _selectedPanelPower.toDouble());
    _batteryCapacity = 0; // Not needed for ON-GRID
  }

  void _calculateOffGrid(double consumption) {
    double dailyConsumption;
    
    if (_isKwh) {
      // Convert monthly kWh to daily kWh (assuming 30 days)
      dailyConsumption = consumption / 30;
    } else {
      // Convert kW to daily kWh (assuming 24 hours operation)
      dailyConsumption = consumption * 24;
    }
    
    _pvPower = ProjectCalculator.offGridPvPower(dailyConsumption, sunHours: _defaultSunHours);
    _estimatedPower = _pvPower;
    _numberOfPanels = ProjectCalculator.offGridPanels(_pvPower, _selectedPanelPower.toDouble());
    _batteryCapacity = ProjectCalculator.offGridBatteryCapacity(dailyConsumption);
  }

  void _calculateHybrid(double consumption) {
    double monthlyConsumption;
    
    if (_isKwh) {
      monthlyConsumption = consumption;
    } else {
      // Convert kW to monthly kWh (assuming 24 hours × 30 days)
      monthlyConsumption = consumption * 24 * 30;
    }
    
    // Calculate solar energy needed (70% coverage by default)
    final solarEnergy = ProjectCalculator.hybridSolarEnergy(monthlyConsumption, coveragePercent: 70.0);
    _pvPower = ProjectCalculator.hybridPvPower(solarEnergy, sunHours: _defaultSunHours);
    _estimatedPower = _pvPower;
    _numberOfPanels = ProjectCalculator.onGridPanels(_pvPower, _selectedPanelPower.toDouble());
    
    // Calculate battery for 1 day of storage
    final dailyEnergy = monthlyConsumption / 30;
    _batteryCapacity = ProjectCalculator.hybridBatteryCapacity(dailyEnergy);
  }

  void _calculatePumping(double consumption) {
    double pumpPower;
    double operatingHours = 8.0; // Default 8 hours per day
    
    if (_isKwh) {
      // If input is kWh/month, convert to pump power
      // Assuming 8 hours operation per day
      final dailyEnergy = consumption / 30;
      pumpPower = dailyEnergy / operatingHours;
    } else {
      // Direct kW input
      pumpPower = consumption;
    }
    
    final dailyEnergy = ProjectCalculator.pumpingEnergy(pumpPower, operatingHours);
    _pvPower = ProjectCalculator.pumpingPvPower(dailyEnergy, sunHours: _defaultSunHours);
    _estimatedPower = _pvPower;
    _numberOfPanels = ProjectCalculator.onGridPanels(_pvPower, _selectedPanelPower.toDouble());
    _batteryCapacity = 0; // Not typically needed for pumping
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.projectStudyTitle),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                  color: _getTypeColor(widget.projectType),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.solar_power, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      widget.projectType,
                      style: const TextStyle(
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

              // Consumption Input
              Text(
                AppLocalizations.of(context)!.electricalConsumption,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumptionController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateEstimatedPower(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la consommation';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Entrez votre consommation',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Unit Toggle
              Text(
                AppLocalizations.of(context)!.unitLabelShort,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isKwh = true);
                          _calculateEstimatedPower();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isKwh ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'kWh/mois',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isKwh ? Colors.white : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isKwh = false);
                          _calculateEstimatedPower();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isKwh ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'kW',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_isKwh ? Colors.white : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Panel Power Dropdown
              Text(
                AppLocalizations.of(context)!.panelPowerW,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
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
                      _calculateEstimatedPower();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Results Card
              if (_estimatedPower > 0) ...[
                ResultCard(
                  projectType: widget.projectType,
                  systemPower: _estimatedPower,
                  pvPower: _pvPower,
                  numberOfPanels: _numberOfPanels.ceil(),
                  batteryCapacity: _batteryCapacity,
                  estimatedSavings: widget.projectType == 'ON-GRID' 
                      ? _estimatedPower * 12 * 1.2 * 365 // Rough estimate: kW × hours × rate × days
                      : null,
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Estimated Power placeholder when no calculation
                Text(
                  AppLocalizations.of(context)!.estimatedInstallationPower,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: colorScheme.onSurfaceVariant, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '0.00 kW',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showConfirmationDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.requestQuoteButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ON-GRID':
        return const Color(0xFFFF9800);
      case 'OFF-GRID':
        return const Color(0xFFF4B400);
      case 'PUMPING':
        return const Color(0xFF4CAF50);
      case 'HYBRID':
        return const Color(0xFF2196F3);
      default:
        return AppColors.primary;
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Demande envoyée'),
          ],
        ),
        content: Text(
          'Votre demande de devis pour un projet ${widget.projectType} '
          'avec une puissance estimée de ${_estimatedPower.toStringAsFixed(2)} kW '
          'a été envoyée avec succès.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

