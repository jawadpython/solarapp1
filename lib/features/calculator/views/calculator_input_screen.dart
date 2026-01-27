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
  String? _selectedVoltage; // 220V or 380V (ON-GRID, HYBRID, and optional for OFF-GRID)
  double? _selectedCoveragePct = 75.0; // Coverage % (30-100) (HYBRID only - removed from ON-GRID)
  String? _selectedOnGridProfile; // Profile for ON-GRID: Maison (45% SC) or Commerce (65% SC), optional (defaults to 45%)
  String? _selectedProfile; // Consumption profile (HYBRID): Maison, Commerce, etc.
  String? _selectedUsageProfile; // Usage profile (OFF-GRID): Maison petite, etc.
  int? _selectedPanelWp = 550; // Default 550W (will change to 600W for OFF-GRID)
  int? _selectedBatteryKwh; // Required for HYBRID
  int? _selectedAutonomyDays; // 1, 2, or 3 (OFF-GRID) - 2 is default
  String? _selectedFlowUnit; // m3/h or L/min (POMPAGE only)
  String? _selectedPumpType; // AC or DC (POMPAGE only)
  
  final List<String> _onGridProfileOptions = ['Maison', 'Commerce']; // ON-GRID profiles
  final List<String> _hybridProfileOptions = ['Maison', 'Commerce', 'Industrie', 'Maison Nuit'];
  final List<String> _offGridUsageProfiles = [
    'Maison petite (rural)',
    'Maison moyenne',
    'Maison grande / Villa rurale',
    'Atelier / Commerce petit',
  ];

  bool _isCalculating = false;
  List<RegionModel> _regions = [];
  bool _isLoadingRegions = true;

  final List<int> _panelWpOptions = [240, 280, 300, 450, 500, 550, 600, 650, 700];
  final List<int> _batteryKwhOptions = [5, 10, 15, 20, 25]; // Extended for HYBRID
  final List<int> _autonomyDaysOptions = [1, 2]; // For OFF-GRID: now [1, 2, 3] handled in dropdown
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
    if (_selectedSystemType == 'ON-GRID') {
      if (_selectedVoltage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllRequiredFields),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Profile is optional - defaults to 45% SC if not selected
    }

    if (_selectedSystemType == 'HYBRID') {
      if (_selectedVoltage == null || _selectedCoveragePct == null || _selectedProfile == null || _selectedBatteryKwh == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllRequiredFields),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_selectedSystemType == 'OFF-GRID') {
      if (_selectedUsageProfile == null || _selectedAutonomyDays == null) {
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
          if (_selectedVoltage == null) {
            throw Exception(AppLocalizations.of(context)!.pleaseSelectNetworkType);
          }
          // Profile is optional - will default to 45% SC if null
          result = await _calculatorService.calculateOnGrid(
            montantDH: montantDH,
            regionCode: _selectedRegionCode!,
            panelWp: _selectedPanelWp ?? 550,
            profile: _selectedOnGridProfile, // Optional - defaults to 45% SC
            voltage: _selectedVoltage!,
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
          if (_selectedVoltage == null || _selectedCoveragePct == null || _selectedProfile == null) {
            throw Exception(AppLocalizations.of(context)!.pleaseFillAllRequiredFieldsNetworkCoverageProfile);
          }
          if (_selectedCoveragePct! < 30 || _selectedCoveragePct! > 90) {
            throw Exception(AppLocalizations.of(context)!.coverageMustBeBetween30And90ForHybrid);
          }
          if (_selectedBatteryKwh == null || _selectedBatteryKwh! <= 0) {
            throw Exception(AppLocalizations.of(context)!.batteryCapacityRequiredForHybridSystem);
          }
          result = await _calculatorService.calculateHybrid(
            montantDH: montantDH,
            regionCode: _selectedRegionCode!,
            panelWp: _selectedPanelWp ?? 550,
            coveragePct: _selectedCoveragePct!,
            batteryKwh: _selectedBatteryKwh!.toDouble(),
            profile: _selectedProfile!,
            voltage: _selectedVoltage!,
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
          if (_selectedUsageProfile == null || _selectedAutonomyDays == null) {
            throw Exception(AppLocalizations.of(context)!.pleaseSelectUsageProfileAndAutonomy);
          }
          result = await _calculatorService.calculateOffGrid(
            profile: _selectedUsageProfile!,
            regionCode: _selectedRegionCode!,
            autonomyDays: _selectedAutonomyDays!,
            panelWp: _selectedPanelWp ?? 600,
            voltage: _selectedVoltage, // Optional
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

              // System Type Selection - Card-based design like the handwritten note
              Text(
                AppLocalizations.of(context)!.chooseSystemType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              // System Type Cards
              _buildSystemTypeCard(
                title: AppLocalizations.of(context)!.onGrid,
                description: AppLocalizations.of(context)!.onGridDescription,
                icon: Icons.bolt,
                value: 'ON-GRID',
                isSelected: _selectedSystemType == 'ON-GRID',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              
              _buildSystemTypeCard(
                title: AppLocalizations.of(context)!.hybrid,
                description: AppLocalizations.of(context)!.hybridDescription,
                icon: Icons.battery_charging_full,
                value: 'HYBRID',
                isSelected: _selectedSystemType == 'HYBRID',
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              
              _buildSystemTypeCard(
                title: AppLocalizations.of(context)!.offGrid,
                description: AppLocalizations.of(context)!.offGridDescription,
                icon: Icons.home,
                value: 'OFF-GRID',
                isSelected: _selectedSystemType == 'OFF-GRID',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              
              _buildSystemTypeCard(
                title: AppLocalizations.of(context)!.pumpingSolarSystem,
                description: AppLocalizations.of(context)!.pumpingSolarDescription,
                icon: Icons.water_drop,
                value: 'POMPAGE SOLAIRE',
                isSelected: _selectedSystemType == 'POMPAGE SOLAIRE',
                color: Colors.cyan,
              ),
              
              if (_selectedSystemType == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 4),
                  child: Text(
                    AppLocalizations.of(context)!.pleaseSelectSystemType,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
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

  // ON-GRID inputs: montantDH, voltage, profile (optional - defaults to 45% SC)
  List<Widget> _buildOnGridInputs() {
    return [
      _buildTextField(
        controller: _montantDHController,
        label: AppLocalizations.of(context)!.monthlyBillAmountDH,
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
      _buildVoltageDropdown(context),
      const SizedBox(height: 24),
      _buildOnGridProfileDropdown(context),
    ];
  }

  // HYBRID inputs: montantDH, voltage, coverage, profile, batteryKwh
  List<Widget> _buildHybridInputs() {
    return [
      _buildTextField(
        controller: _montantDHController,
        label: AppLocalizations.of(context)!.monthlyBillDH,
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
      _buildVoltageDropdown(context),
      const SizedBox(height: 24),
      _buildCoverageSlider(context),
      const SizedBox(height: 24),
      _buildProfileDropdown(context),
      const SizedBox(height: 24),
      _buildBatteryKwhDropdown(context, required: true),
    ];
  }
  
  Widget _buildProfileDropdown(BuildContext context) {
    return _buildDropdown<String>(
      label: AppLocalizations.of(context)!.consumptionProfileDayNight,
      value: _selectedProfile,
      hint: AppLocalizations.of(context)!.selectProfile,
      items: _hybridProfileOptions.map((profile) {
        String description;
        final loc = AppLocalizations.of(context)!;
        switch (profile) {
          case 'Maison':
            description = loc.houseProfile60Day40Night;
            break;
          case 'Commerce':
            description = loc.commerceProfile80Day20Night;
            break;
          case 'Industrie':
            description = loc.industryProfile90Day10Night;
            break;
          case 'Maison Nuit':
            description = loc.houseNightProfile40Day60Night;
            break;
          default:
            description = profile;
        }
        return DropdownMenuItem(value: profile, child: Text(description));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedProfile = value);
      },
    );
  }

  // OFF-GRID inputs: usage profile, autonomy, voltage (optional), panel power (optional)
  List<Widget> _buildOffGridInputs() {
    return [
      _buildUsageProfileDropdown(context),
      const SizedBox(height: 24),
      _buildAutonomyDaysDropdown(context),
      const SizedBox(height: 24),
      _buildVoltageDropdown(context, required: false), // Optional but recommended
    ];
  }

  Widget _buildUsageProfileDropdown(BuildContext context) {
    return _buildDropdown<String>(
      label: AppLocalizations.of(context)!.usageProfile,
      value: _selectedUsageProfile,
      hint: AppLocalizations.of(context)!.selectProfile,
      items: _offGridUsageProfiles.map((profile) {
        String description;
        double kwhDay;
        final loc = AppLocalizations.of(context)!;
        switch (profile) {
          case 'Maison petite (rural)':
            kwhDay = 5.0;
            description = '${loc.smallHouseRural} → E_day = 5 kWh/day';
            break;
          case 'Maison moyenne':
            kwhDay = 10.0;
            description = '${loc.mediumHouse} → E_day = 10 kWh/day';
            break;
          case 'Maison grande / Villa rurale':
            kwhDay = 20.0;
            description = '${loc.largeHouseRuralVilla} → E_day = 20 kWh/day';
            break;
          case 'Atelier / Commerce petit':
            kwhDay = 30.0;
            description = '${loc.workshopSmallBusiness} → E_day = 30 kWh/day';
            break;
          default:
            description = profile;
            kwhDay = 10.0;
        }
        return DropdownMenuItem(value: profile, child: Text(description));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedUsageProfile = value);
      },
    );
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

  Widget _buildVoltageDropdown(BuildContext context, {bool required = true}) {
    return _buildDropdown<String>(
      label: required ? AppLocalizations.of(context)!.network : AppLocalizations.of(context)!.internalNetworkOptional,
      value: _selectedVoltage,
      hint: AppLocalizations.of(context)!.select220VOr380V,
      items: [
        DropdownMenuItem(value: '220V', child: Text(AppLocalizations.of(context)!.voltage220VSinglePhase)),
        DropdownMenuItem(value: '380V', child: Text(AppLocalizations.of(context)!.voltage380VThreePhase)),
      ],
      onChanged: (value) {
        setState(() => _selectedVoltage = value);
      },
    );
  }

  Widget _buildOnGridProfileDropdown(BuildContext context) {
    return _buildDropdown<String>(
      label: AppLocalizations.of(context)!.profileOptional,
      value: _selectedOnGridProfile,
      hint: AppLocalizations.of(context)!.selectProfileDefaultHouse45,
      items: [
        DropdownMenuItem(
          value: 'Maison',
          child: Text(AppLocalizations.of(context)!.houseResidential45SelfConsumption),
        ),
        DropdownMenuItem(
          value: 'Commerce',
          child: Text(AppLocalizations.of(context)!.commerceCommercial65SelfConsumption),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedOnGridProfile = value);
      },
    );
  }

  Widget _buildCoverageSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.desiredCoveragePercent,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '30%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedCoveragePct?.toStringAsFixed(0) ?? 75}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    _selectedSystemType == 'HYBRID' ? '90%' : '100%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _selectedCoveragePct ?? 75.0,
                min: 30,
                max: _selectedSystemType == 'HYBRID' ? 90.0 : 100.0,
                divisions: _selectedSystemType == 'HYBRID' ? 60 : 70,
                label: '${_selectedCoveragePct?.toStringAsFixed(0) ?? 75}%',
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _selectedCoveragePct = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
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
    // OFF-GRID: 1, 2 (default), or 3 days
    final offGridAutonomyOptions = [1, 2, 3];
    return _buildDropdown<int>(
      label: AppLocalizations.of(context)!.autonomy,
      value: _selectedAutonomyDays,
      hint: AppLocalizations.of(context)!.selectAutonomy2DaysDefault,
      items: offGridAutonomyOptions.map((days) {
        final dayText = days == 1 ? loc.day : loc.days;
        final defaultText = days == 2 ? AppLocalizations.of(context)!.dayDefault : '';
        return DropdownMenuItem(value: days, child: Text('$days $dayText$defaultText'));
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

  /// Build system type selection card (like the handwritten note design)
  Widget _buildSystemTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required bool isSelected,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSystemType = value;
          // Clear all inputs when system type changes
          _montantDHController.clear();
          _kwhPerDayController.clear();
          _flowValueController.clear();
          _hmtMetersController.clear();
          _hoursPerDayController.clear();
          _selectedVoltage = null;
          _selectedCoveragePct = 75.0;
          _selectedOnGridProfile = null;
          _selectedProfile = null;
          _selectedUsageProfile = null;
          _selectedBatteryKwh = null;
          _selectedFlowUnit = null;
          _selectedPumpType = null;
          // Set defaults based on system type
          if (value == 'OFF-GRID') {
            _selectedAutonomyDays = 2; // Default for OFF-GRID
            _selectedPanelWp = 600; // Default 600W for OFF-GRID
          } else {
            _selectedAutonomyDays = null;
            _selectedPanelWp = 550; // Default 550W for other systems
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon in left side
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
