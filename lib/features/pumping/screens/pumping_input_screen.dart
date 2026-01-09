import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/features/pumping/models/pumping_input.dart';
import 'package:noor_energy/features/pumping/screens/pumping_result_screen.dart';
import 'package:noor_energy/features/pumping/services/pumping_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class PumpingInputScreen extends StatefulWidget {
  const PumpingInputScreen({super.key});

  @override
  State<PumpingInputScreen> createState() => _PumpingInputScreenState();
}

class _PumpingInputScreenState extends State<PumpingInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pumpingService = PumpingService();
  final _regionService = RegionService.instance;

  PumpingMode? _selectedMode;
  bool _isCalculating = false;

  // FLOW MODE controllers
  final _flowValueController = TextEditingController();
  FlowUnit? _selectedFlowUnit;
  final _headMetersController = TextEditingController();
  final _hoursPerDayFlowController = TextEditingController();

  // AREA MODE controllers
  final _areaValueController = TextEditingController();
  AreaUnit? _selectedAreaUnit;
  String? _selectedCropType;
  String? _selectedIrrigationType;
  final _hoursPerDayAreaController = TextEditingController();
  final _headMetersAreaController = TextEditingController();

  // TANK MODE controllers
  final _tankVolumeController = TextEditingController();
  final _fillHoursController = TextEditingController();
  final _wellDepthController = TextEditingController();
  final _tankHeightController = TextEditingController();

  // Shared
  String? _selectedRegionCode;
  CurrentSource? _selectedCurrentSource;
  List<RegionModel> _regions = [];
  bool _isLoadingRegions = true;

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
      }
    }
  }

  @override
  void dispose() {
    _flowValueController.dispose();
    _headMetersController.dispose();
    _hoursPerDayFlowController.dispose();
    _areaValueController.dispose();
    _hoursPerDayAreaController.dispose();
    _headMetersAreaController.dispose();
    _tankVolumeController.dispose();
    _fillHoursController.dispose();
    _wellDepthController.dispose();
    _tankHeightController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectCalculationMethod),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_selectedRegionCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectYourRegion),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_selectedCurrentSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectYourEnergySource),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      PumpingInput input;

      switch (_selectedMode!) {
        case PumpingMode.flow:
          final flowValue = double.tryParse(_flowValueController.text);
          final headMeters = double.tryParse(_headMetersController.text);
          final hoursPerDay = double.tryParse(_hoursPerDayFlowController.text);
          
          if (flowValue == null || headMeters == null || hoursPerDay == null || _selectedFlowUnit == null) {
            throw Exception(AppLocalizations.of(context)!.invalidValues);
          }

          input = PumpingInput.flow(
            flowValue: flowValue,
            flowUnit: _selectedFlowUnit!,
            headMeters: headMeters,
            hoursPerDay: hoursPerDay,
            regionCode: _selectedRegionCode!,
            currentSource: _selectedCurrentSource!,
          );
          break;

        case PumpingMode.area:
          final areaValue = double.tryParse(_areaValueController.text);
          final headMeters = double.tryParse(_headMetersAreaController.text);
          final hoursPerDay = double.tryParse(_hoursPerDayAreaController.text);
          
          if (areaValue == null || headMeters == null || hoursPerDay == null ||
              _selectedAreaUnit == null || _selectedCropType == null || _selectedIrrigationType == null) {
            throw Exception(AppLocalizations.of(context)!.invalidValues);
          }

          input = PumpingInput.area(
            areaValue: areaValue,
            areaUnit: _selectedAreaUnit!,
            cropType: _selectedCropType!,
            irrigationType: _selectedIrrigationType!,
            hoursPerDay: hoursPerDay,
            headMeters: headMeters,
            regionCode: _selectedRegionCode!,
            currentSource: _selectedCurrentSource!,
          );
          break;

        case PumpingMode.tank:
          final tankVolume = double.tryParse(_tankVolumeController.text);
          final fillHours = double.tryParse(_fillHoursController.text);
          final wellDepth = double.tryParse(_wellDepthController.text);
          final tankHeight = double.tryParse(_tankHeightController.text);
          
          if (tankVolume == null || fillHours == null || wellDepth == null || tankHeight == null) {
            throw Exception(AppLocalizations.of(context)!.invalidValues);
          }

          input = PumpingInput.tank(
            tankVolumeM3: tankVolume,
            fillHours: fillHours,
            wellDepthM: wellDepth,
            tankHeightM: tankHeight,
            regionCode: _selectedRegionCode!,
            currentSource: _selectedCurrentSource!,
          );
          break;
      }

      final result = await _pumpingService.calculate(input);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PumpingResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.calculationError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.ok,
              textColor: Colors.white,
              onPressed: () {},
            ),
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
        title: Text(AppLocalizations.of(context)!.pumpingSolar),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Header Introduction Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.pumpingSolarDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.pumpingSolarSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Step 1
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.step1ChooseMethod,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ModeCard(
                title: AppLocalizations.of(context)!.modeFlowTitle,
                description: AppLocalizations.of(context)!.modeFlowDescription,
                icon: Icons.water_drop,
                isSelected: _selectedMode == PumpingMode.flow,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.flow;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: AppLocalizations.of(context)!.modeAreaTitle,
                description: AppLocalizations.of(context)!.modeAreaDescription,
                icon: Icons.agriculture,
                isSelected: _selectedMode == PumpingMode.area,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.area;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: AppLocalizations.of(context)!.modeTankTitle,
                description: AppLocalizations.of(context)!.modeTankDescription,
                icon: Icons.water,
                isSelected: _selectedMode == PumpingMode.tank,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.tank;
                  });
                },
              ),
              const SizedBox(height: 40),
              
              // Step 2
              if (_selectedMode != null) ...[
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.step2EnterInfo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              
              // Mode-specific forms
              if (_selectedMode == PumpingMode.flow) _buildFlowForm(),
              if (_selectedMode == PumpingMode.area) _buildAreaForm(),
              if (_selectedMode == PumpingMode.tank) _buildTankForm(),
              
              // Region selection (always shown)
              const SizedBox(height: 24),
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
                            setState(() {
                              _selectedRegionCode = value;
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Current source selection
              Text(
                '${AppLocalizations.of(context)!.currentEnergySource} *',
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
                  child: DropdownButton<CurrentSource>(
                    value: _selectedCurrentSource,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: Text(AppLocalizations.of(context)!.selectSource),
                    items: [
                      DropdownMenuItem(
                        value: CurrentSource.electricity,
                        child: Text(AppLocalizations.of(context)!.electricity),
                      ),
                      DropdownMenuItem(
                        value: CurrentSource.diesel,
                        child: Text(AppLocalizations.of(context)!.diesel),
                      ),
                      DropdownMenuItem(
                        value: CurrentSource.unknown,
                        child: Text(AppLocalizations.of(context)!.unknown),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrentSource = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Step 3
              if (_selectedMode != null && _selectedRegionCode != null && _selectedCurrentSource != null) ...[
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.step3Calculate,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              
              // Calculate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculate,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${AppLocalizations.of(context)!.flow} *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _flowValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le débit';
                  }
                  final numValue = double.tryParse(value);
                  if (numValue == null) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  if (numValue <= 0) {
                    return 'Le débit doit être supérieur à 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 10',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FlowUnit>(
                    value: _selectedFlowUnit,
                    isExpanded: true,
                    hint: Text(AppLocalizations.of(context)!.unit),
                    items: [
                      DropdownMenuItem(value: FlowUnit.m3h, child: Text(AppLocalizations.of(context)!.flowUnitM3h)),
                      DropdownMenuItem(value: FlowUnit.lmin, child: Text(AppLocalizations.of(context)!.flowUnitLmin)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFlowUnit = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _headMetersController,
          label: '${AppLocalizations.of(context)!.headMeters} *',
          hint: 'Ex: 50',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _hoursPerDayFlowController,
          label: '${AppLocalizations.of(context)!.operatingHoursPerDay} *',
          hint: 'Ex: 8',
        ),
      ],
    );
  }

  Widget _buildAreaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${AppLocalizations.of(context)!.surface} *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _areaValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le débit';
                  }
                  final numValue = double.tryParse(value);
                  if (numValue == null) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  if (numValue <= 0) {
                    return 'Le débit doit être supérieur à 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ex: 5',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AreaUnit>(
                    value: _selectedAreaUnit,
                    isExpanded: true,
                    hint: Text(AppLocalizations.of(context)!.unit),
                    items: [
                      DropdownMenuItem(value: AreaUnit.m2, child: Text(AppLocalizations.of(context)!.areaUnitM2)),
                      DropdownMenuItem(value: AreaUnit.ha, child: Text(AppLocalizations.of(context)!.areaUnitHa)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaUnit = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '${AppLocalizations.of(context)!.cropType} *',
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
            child: DropdownButton<String>(
              value: _selectedCropType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: Text(AppLocalizations.of(context)!.selectCropType),
              items: PumpingService.getCropTypes().map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCropType = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${AppLocalizations.of(context)!.irrigationType} *',
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
            child: DropdownButton<String>(
              value: _selectedIrrigationType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: Text(AppLocalizations.of(context)!.selectIrrigationType),
              items: PumpingService.getIrrigationTypes().map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIrrigationType = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _hoursPerDayAreaController,
          label: '${AppLocalizations.of(context)!.operatingHoursPerDay} *',
          hint: 'Ex: 8',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _headMetersAreaController,
          label: '${AppLocalizations.of(context)!.headMeters} *',
          hint: 'Ex: 50',
        ),
      ],
    );
  }

  Widget _buildTankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _tankVolumeController,
          label: '${AppLocalizations.of(context)!.tankVolume} *',
          hint: 'Ex: 50',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _fillHoursController,
          label: '${AppLocalizations.of(context)!.fillTime} *',
          hint: 'Ex: 4',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _wellDepthController,
          label: '${AppLocalizations.of(context)!.wellDepth} *',
          hint: 'Ex: 30',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _tankHeightController,
          label: '${AppLocalizations.of(context)!.tankHeight} *',
          hint: 'Ex: 5',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.fieldRequired;
            }
            final numValue = double.tryParse(value);
            if (numValue == null) {
              return AppLocalizations.of(context)!.enterValidNumber;
            }
            if (numValue <= 0) {
              return AppLocalizations.of(context)!.valueMustBeGreater;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 4 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 3 : 1.5,
          ),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

