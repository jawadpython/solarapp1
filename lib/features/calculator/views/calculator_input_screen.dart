import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/models/calculator_result.dart';
import 'package:noor_energy/features/calculator/services/calculator_v1_service.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/features/calculator/screens/result_on_grid_screen.dart';
import 'package:noor_energy/features/calculator/screens/result_hybrid_screen.dart';
import 'package:noor_energy/features/calculator/screens/result_off_grid_screen.dart';
import 'package:noor_energy/features/calculator/screens/result_pumping_screen.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class CalculatorInputScreen extends StatefulWidget {
  const CalculatorInputScreen({super.key});

  @override
  State<CalculatorInputScreen> createState() => _CalculatorInputScreenState();
}

class _CalculatorInputScreenState extends State<CalculatorInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calculatorService = CalculatorV1Service();
  final _regionService = RegionService.instance;

  // System type (mandatory first field)
  String? _selectedSystemType;

  // Controllers for all possible inputs
  final _montantDHController = TextEditingController();
  final _kwhPerDayController = TextEditingController();
  final _flowValueController = TextEditingController();
  final _hmtMetersController = TextEditingController();
  final _hoursPerDayController = TextEditingController();

  // Dropdown values
  String? _selectedRegionCode;
  String? _selectedUsageType; // Maison / Commerce (ON-GRID only)
  int? _selectedPanelWp = 550;
  int? _selectedBatteryKwh; // Optional for HYBRID, required for OFF-GRID
  int? _selectedAutonomyDays; // 1 or 2 (OFF-GRID only)
  String? _selectedFlowUnit; // m3/h or L/min (POMPAGE only)
  String? _selectedPumpType; // AC or DC (POMPAGE only)

  bool _isCalculating = false;
  List<RegionModel> _regions = [];
  bool _isLoadingRegions = true;

  final List<int> _panelWpOptions = [240, 280, 300, 450, 500, 550, 600];
  final List<int> _batteryKwhOptions = [5, 10, 15, 20];
  final List<int> _autonomyDaysOptions = [1, 2];
  final List<String> _flowUnitOptions = ['m3/h', 'L/min'];
  final List<String> _pumpTypeOptions = ['AC', 'DC'];

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final regions = await _regionService.loadRegions();
      if (mounted) {
        setState(() {
          _regions = regions;
          _isLoadingRegions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRegions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorLoadingRegions}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _montantDHController.dispose();
    _kwhPerDayController.dispose();
    _flowValueController.dispose();
    _hmtMetersController.dispose();
    _hoursPerDayController.dispose();
    super.dispose();
  }

  /// Parse number accepting both comma and dot
  double? _parseNumber(String value) {
    if (value.isEmpty) return null;
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _submitForm() async {
    // Validate system type is selected
    if (_selectedSystemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectSystemTypeError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate region
    if (_selectedRegionCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectRegionError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // System-specific validation
    if (_selectedSystemType == 'OFF-GRID') {
      if (_selectedBatteryKwh == null || _selectedAutonomyDays == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllRequiredFields),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_selectedSystemType == 'POMPAGE SOLAIRE') {
      if (_selectedFlowUnit == null || _selectedPumpType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllRequiredFields),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      CalculatorResult result;

      switch (_selectedSystemType!) {
        case 'ON-GRID':
          final montantDH = _parseNumber(_montantDHController.text);
          if (montantDH == null || montantDH <= 0) {
            throw Exception(AppLocalizations.of(context)!.invalidAmount);
          }
          result = await _calculatorService.calculateOnGrid(
            montantDH: montantDH,
            regionCode: _selectedRegionCode!,
            usageType: _selectedUsageType ?? 'Maison',
            panelWp: _selectedPanelWp ?? 550,
          );
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultOnGridScreen(result: result as OnGridResult),
              ),
            );
          }
          break;

        case 'HYBRID':
          final montantDH = _parseNumber(_montantDHController.text);
          if (montantDH == null || montantDH <= 0) {
            throw Exception(AppLocalizations.of(context)!.invalidAmount);
          }
          result = await _calculatorService.calculateHybrid(
            montantDH: montantDH,
            regionCode: _selectedRegionCode!,
            panelWp: _selectedPanelWp ?? 550,
            batteryKwh: _selectedBatteryKwh,
          );
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultHybridScreen(result: result as HybridResult),
              ),
            );
          }
          break;

        case 'OFF-GRID':
          final kwhPerDay = _parseNumber(_kwhPerDayController.text);
          if (kwhPerDay == null || kwhPerDay <= 0) {
            throw Exception(AppLocalizations.of(context)!.invalidConsumption);
          }
          if (_selectedBatteryKwh == null || _selectedAutonomyDays == null) {
            throw Exception(AppLocalizations.of(context)!.batteryAndAutonomyRequired);
          }
          result = await _calculatorService.calculateOffGrid(
            kwhPerDay: kwhPerDay,
            regionCode: _selectedRegionCode!,
            autonomyDays: _selectedAutonomyDays!,
            batteryKwh: _selectedBatteryKwh!.toDouble(),
            panelWp: _selectedPanelWp ?? 550,
          );
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultOffGridScreen(result: result as OffGridResult),
              ),
            );
          }
          break;

        case 'POMPAGE SOLAIRE':
          final flowValue = _parseNumber(_flowValueController.text);
          final hmtMeters = _parseNumber(_hmtMetersController.text);
          final hoursPerDay = _parseNumber(_hoursPerDayController.text);
          if (flowValue == null || flowValue <= 0 ||
              hmtMeters == null || hmtMeters <= 0 ||
              hoursPerDay == null || hoursPerDay <= 0) {
            throw Exception(AppLocalizations.of(context)!.invalidValues);
          }
          result = await _calculatorService.calculatePumping(
            flowValue: flowValue,
            flowUnit: _selectedFlowUnit!,
            hmtMeters: hmtMeters,
            hoursPerDay: hoursPerDay,
            regionCode: _selectedRegionCode!,
            pumpType: _selectedPumpType!,
            panelWp: _selectedPanelWp ?? 550,
          );
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPumpingScreen(result: result as PumpingResult),
              ),
            );
          }
          break;

        default:
          throw Exception(AppLocalizations.of(context)!.invalidSystemType);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorPrefix}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.solarCalculator),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // System Type Dropdown (MANDATORY FIRST FIELD)
              Text(
                AppLocalizations.of(context)!.systemTypeRequired,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
                  child: DropdownButton<String>(
                    value: _selectedSystemType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: Text(AppLocalizations.of(context)!.selectSystemTypeHint),
                    items: [
                      DropdownMenuItem(value: 'ON-GRID', child: Text(AppLocalizations.of(context)!.onGrid)),
                      DropdownMenuItem(value: 'HYBRID', child: Text(AppLocalizations.of(context)!.hybrid)),
                      DropdownMenuItem(value: 'OFF-GRID', child: Text(AppLocalizations.of(context)!.offGrid)),
                      DropdownMenuItem(value: 'POMPAGE SOLAIRE', child: Text(AppLocalizations.of(context)!.pumpingSolarSystem)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSystemType = value;
                        // Clear all inputs when system type changes
                        _montantDHController.clear();
                        _kwhPerDayController.clear();
                        _flowValueController.clear();
                        _hmtMetersController.clear();
                        _hoursPerDayController.clear();
                        _selectedUsageType = null;
                        _selectedBatteryKwh = null;
                        _selectedAutonomyDays = null;
                        _selectedFlowUnit = null;
                        _selectedPumpType = null;
                      });
                    },
                  ),
                ),
              ),
              if (_selectedSystemType == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    AppLocalizations.of(context)!.fieldRequired,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Dynamic inputs based on system type
              if (_selectedSystemType != null) ...[
                // ON-GRID inputs
                if (_selectedSystemType == 'ON-GRID') ..._buildOnGridInputs(),

                // HYBRID inputs
                if (_selectedSystemType == 'HYBRID') ..._buildHybridInputs(),

                // OFF-GRID inputs
                if (_selectedSystemType == 'OFF-GRID') ..._buildOffGridInputs(),

                // POMPAGE inputs
                if (_selectedSystemType == 'POMPAGE SOLAIRE') ..._buildPumpingInputs(),

                // Common fields: Region and Panel WP
                const SizedBox(height: 24),
                _buildRegionDropdown(),
                const SizedBox(height: 24),
                _buildPanelWpDropdown(),
                const SizedBox(height: 32),

                // Calculate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCalculating ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isCalculating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.calculate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ON-GRID inputs: montantDH, usageType
  List<Widget> _buildOnGridInputs() {
    return [
      _buildTextField(
        controller: _montantDHController,
        label: AppLocalizations.of(context)!.billAmountLabel,
        hint: AppLocalizations.of(context)!.billAmountExample,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          final num = _parseNumber(value);
          if (num == null) {
            return AppLocalizations.of(context)!.enterValidNumber;
          }
          if (num <= 0) {
            return AppLocalizations.of(context)!.amountMustBeGreaterThanZero;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildUsageTypeDropdown(context),
    ];
  }

  // HYBRID inputs: montantDH, batteryKwh (optional)
  List<Widget> _buildHybridInputs() {
    return [
      _buildTextField(
        controller: _montantDHController,
        label: AppLocalizations.of(context)!.billAmountLabel,
        hint: AppLocalizations.of(context)!.billAmountExample,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          final num = _parseNumber(value);
          if (num == null) {
            return AppLocalizations.of(context)!.enterValidNumber;
          }
          if (num <= 0) {
            return AppLocalizations.of(context)!.amountMustBeGreaterThanZero;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildBatteryKwhDropdown(context, required: false),
    ];
  }

  // OFF-GRID inputs: kwhPerDay, autonomyDays, batteryKwh
  List<Widget> _buildOffGridInputs() {
    return [
      _buildTextField(
        controller: _kwhPerDayController,
        label: AppLocalizations.of(context)!.consumptionPerDay,
        hint: AppLocalizations.of(context)!.consumptionExample,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          final num = _parseNumber(value);
          if (num == null) {
            return AppLocalizations.of(context)!.enterValidNumber;
          }
          if (num <= 0) {
            return AppLocalizations.of(context)!.consumptionMustBeGreater;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildAutonomyDaysDropdown(context),
      const SizedBox(height: 24),
      _buildBatteryKwhDropdown(context, required: true),
    ];
  }

  // POMPAGE inputs: flowValue, flowUnit, hmtMeters, hoursPerDay, pumpType
  List<Widget> _buildPumpingInputs() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildTextField(
              controller: _flowValueController,
              label: AppLocalizations.of(context)!.flowLabel,
              hint: AppLocalizations.of(context)!.flowExample,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.fieldRequired;
                }
                final num = _parseNumber(value);
                if (num == null) {
                  return AppLocalizations.of(context)!.enterValidNumber;
                }
                if (num <= 0) {
                  return AppLocalizations.of(context)!.flowMustBeGreaterThanZero;
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown<String>(
              label: AppLocalizations.of(context)!.unitLabel,
              value: _selectedFlowUnit,
              hint: AppLocalizations.of(context)!.unitHint,
              items: _flowUnitOptions.map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedFlowUnit = value);
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _buildTextField(
        controller: _hmtMetersController,
        label: AppLocalizations.of(context)!.headMetersLabel,
        hint: AppLocalizations.of(context)!.headExample,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          final num = _parseNumber(value);
          if (num == null) {
            return AppLocalizations.of(context)!.enterValidNumber;
          }
          if (num <= 0) {
            return AppLocalizations.of(context)!.headMustBeGreater;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildTextField(
        controller: _hoursPerDayController,
        label: AppLocalizations.of(context)!.operatingHoursLabel,
        hint: AppLocalizations.of(context)!.hoursExample,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          final num = _parseNumber(value);
          if (num == null) {
            return AppLocalizations.of(context)!.enterValidNumber;
          }
          if (num <= 0) {
            return AppLocalizations.of(context)!.hoursMustBeGreater;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildDropdown<String>(
        label: AppLocalizations.of(context)!.pumpTypeLabel,
        value: _selectedPumpType,
        hint: AppLocalizations.of(context)!.selectPumpTypeHint,
        items: _pumpTypeOptions.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedPumpType = value);
        },
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }

  Widget _buildUsageTypeDropdown(BuildContext context) {
    return _buildDropdown<String>(
      label: AppLocalizations.of(context)!.usageTypeLabel,
      value: _selectedUsageType,
      hint: AppLocalizations.of(context)!.selectUsageTypeHint,
      items: [
        DropdownMenuItem(value: 'Maison', child: Text(AppLocalizations.of(context)!.house)),
        DropdownMenuItem(value: 'Commerce', child: Text(AppLocalizations.of(context)!.commerce)),
      ],
      onChanged: (value) {
        setState(() => _selectedUsageType = value);
      },
    );
  }

  Widget _buildBatteryKwhDropdown(BuildContext context, {required bool required}) {
    return _buildDropdown<int>(
      label: required ? AppLocalizations.of(context)!.batteryCapacityRequired : AppLocalizations.of(context)!.batteryCapacity,
      value: _selectedBatteryKwh,
      hint: AppLocalizations.of(context)!.selectBatteryCapacity,
      items: _batteryKwhOptions.map((kwh) {
        return DropdownMenuItem(value: kwh, child: Text('$kwh kWh'));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBatteryKwh = value);
      },
    );
  }

  Widget _buildAutonomyDaysDropdown(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return _buildDropdown<int>(
      label: loc.autonomyDays,
      value: _selectedAutonomyDays,
      hint: loc.selectAutonomy,
      items: _autonomyDaysOptions.map((days) {
        final dayText = days == 1 ? loc.day : loc.days;
        return DropdownMenuItem(value: days, child: Text('$days $dayText'));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedAutonomyDays = value);
      },
    );
  }

  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.region} *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
            child: _isLoadingRegions
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButton<String>(
                    value: _selectedRegionCode,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: Text(AppLocalizations.of(context)!.selectRegionHint),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region.regionCode,
                        child: Text(region.regionNameFr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedRegionCode = value);
                    },
                  ),
          ),
        ),
        if (_selectedRegionCode == null && !_isLoadingRegions)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              AppLocalizations.of(context)!.fieldRequired,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPanelWpDropdown() {
    return _buildDropdown<int>(
      label: AppLocalizations.of(context)!.panelPower,
      value: _selectedPanelWp,
      hint: AppLocalizations.of(context)!.selectHint,
      items: _panelWpOptions.map((wp) {
        return DropdownMenuItem(value: wp, child: Text('$wp W'));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedPanelWp = value);
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: Text(hint),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
