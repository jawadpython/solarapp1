import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/project_study/widgets/result_card.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:noor_energy/routes/app_routes.dart';

class PumpingFormScreen extends StatefulWidget {
  const PumpingFormScreen({super.key});

  @override
  State<PumpingFormScreen> createState() => _PumpingFormScreenState();
}

class _PumpingFormScreenState extends State<PumpingFormScreen> {
  // Default sun hours constant
  static const double _defaultSunHours = 5.5;

  final _formKey = GlobalKey<FormState>();
  final _pumpPowerController = TextEditingController();
  final _pumpDepthController = TextEditingController();
  final _workingHoursController = TextEditingController(text: '8');
  
  bool _isKw = true;
  int _selectedPanelPower = 550;
  double _pvPower = 0;
  double _numberOfPanels = 0;
  double _systemPower = 0;

  final List<int> _panelPowers = [400, 450, 500, 550, 600, 650, 700];

  @override
  void dispose() {
    _pumpPowerController.dispose();
    _pumpDepthController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  void _calculate() {
    final pumpPowerInput = double.tryParse(_pumpPowerController.text) ?? 0;
    final depthMeters = double.tryParse(_pumpDepthController.text) ?? 0;
    final hours = double.tryParse(_workingHoursController.text) ?? 8;

    // Safe division by zero check
    if (pumpPowerInput > 0 && depthMeters > 0 && hours > 0 && _defaultSunHours > 0) {
      double pumpPowerKw;
      
      if (_isKw) {
        pumpPowerKw = pumpPowerInput;
      } else {
        // Convert HP to kW (1 HP = 0.746 kW)
        pumpPowerKw = pumpPowerInput * 0.746;
      }
      
      // Include depth impact (HMT) so this input affects sizing.
      // 40 m is the baseline depth used by current business examples.
      final depthFactor = (depthMeters / 40).clamp(0.5, 3.0);
      final dailyEnergy = pumpPowerKw * hours * depthFactor;
      
      // PvKw = DailyEnergy / SunHours
      _pvPower = dailyEnergy / _defaultSunHours;
      _systemPower = _pvPower;
      
      // Panels = (PvKw * 1000) / panelWp (using selected panel power)
      if (_selectedPanelPower > 0) {
        _numberOfPanels = (_pvPower * 1000) / _selectedPanelPower;
      } else {
        _numberOfPanels = 0;
      }
      
      setState(() {});
    } else {
      setState(() {
        _pvPower = 0;
        _numberOfPanels = 0;
        _systemPower = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pumpingStudyTitle),
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
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.solar_power, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'PUMPING',
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

              // Pump Power Unit Toggle
              Text(
                AppLocalizations.of(context)!.powerUnit,
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
                          setState(() => _isKw = true);
                          _calculate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isKw ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'kW',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isKw ? Colors.white : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isKw = false);
                          _calculate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isKw ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'HP',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_isKw ? Colors.white : colorScheme.onSurfaceVariant,
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

              // Pump Power
              Text(
                AppLocalizations.of(context)!.pumpPowerKwHp(_isKw ? 'kW' : 'HP'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pumpPowerController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la puissance';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: _isKw ? 'Ex: 2.5' : 'Ex: 3.5',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
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
              const SizedBox(height: 24),

              // Pump Depth
              Text(
                AppLocalizations.of(context)!.wellDepthM,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pumpDepthController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la profondeur';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 50',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
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
              const SizedBox(height: 24),

              // Working Hours
              Text(
                AppLocalizations.of(context)!.workingHoursPerDay,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _workingHoursController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les heures';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 8',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
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
              const SizedBox(height: 24),

              // Panel Power
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
                      setState(() {
                        _selectedPanelPower = value!;
                        _calculate();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Results Card
              if (_pvPower > 0) ...[
                ResultCard(
                  projectType: 'PUMPING',
                  systemPower: _systemPower,
                  pvPower: _pvPower,
                  numberOfPanels: _numberOfPanels.ceil(),
                  batteryCapacity: 0,
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
                                'systemType': 'PUMPING',
                                'panels': _numberOfPanels.ceil(),
                                'systemPower': _pvPower,
                                'batteryCapacity': null,
                              },
                            );
                          }
                        : null,
                    icon: const Icon(Icons.request_quote, size: 24),
                    label: Text(
                      AppLocalizations.of(context)!.requestQuoteButton,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: colorScheme.outline,
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

