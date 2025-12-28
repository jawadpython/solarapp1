import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/features/pumping/models/pumping_input.dart';
import 'package:noor_energy/features/pumping/screens/pumping_result_screen.dart';
import 'package:noor_energy/features/pumping/services/pumping_service.dart';

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
    if (_selectedMode == null || _selectedRegionCode == null || _selectedCurrentSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
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
            throw Exception('Valeurs invalides');
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
            throw Exception('Valeurs invalides');
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
            throw Exception('Valeurs invalides');
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
            content: Text('Erreur lors du calcul: $e'),
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
        title: const Text('Pompage Solaire'),
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
              // Mode Selection
              const Text(
                'Comment voulez-vous calculer ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'J\'ai un débit (Q)',
                icon: Icons.water_drop,
                isSelected: _selectedMode == PumpingMode.flow,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.flow;
                  });
                },
              ),
              const SizedBox(height: 12),
              _ModeCard(
                title: 'J\'ai une surface de terrain',
                icon: Icons.landscape,
                isSelected: _selectedMode == PumpingMode.area,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.area;
                  });
                },
              ),
              const SizedBox(height: 12),
              _ModeCard(
                title: 'J\'ai un réservoir d\'eau',
                icon: Icons.water,
                isSelected: _selectedMode == PumpingMode.tank,
                onTap: () {
                  setState(() {
                    _selectedMode = PumpingMode.tank;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Mode-specific forms
              if (_selectedMode == PumpingMode.flow) _buildFlowForm(),
              if (_selectedMode == PumpingMode.area) _buildAreaForm(),
              if (_selectedMode == PumpingMode.tank) _buildTankForm(),
              
              // Region selection (always shown)
              const SizedBox(height: 24),
              const Text(
                'Région *',
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
                  child: _isLoadingRegions
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : DropdownButton<String>(
                          value: _selectedRegionCode,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          hint: const Text('Sélectionnez une région'),
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
              const Text(
                'Source d\'énergie actuelle *',
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
                  child: DropdownButton<CurrentSource>(
                    value: _selectedCurrentSource,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: const Text('Sélectionnez une source'),
                    items: const [
                      DropdownMenuItem(
                        value: CurrentSource.electricity,
                        child: Text('Électricité'),
                      ),
                      DropdownMenuItem(
                        value: CurrentSource.diesel,
                        child: Text('Diesel'),
                      ),
                      DropdownMenuItem(
                        value: CurrentSource.unknown,
                        child: Text('Je ne sais pas'),
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
                      : const Text(
                          'Calculer',
                          style: TextStyle(
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
        const Text(
          'Débit *',
          style: TextStyle(
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
                    return 'Requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nombre invalide';
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
                    hint: const Text('Unité'),
                    items: const [
                      DropdownMenuItem(value: FlowUnit.m3h, child: Text('m³/h')),
                      DropdownMenuItem(value: FlowUnit.lmin, child: Text('L/min')),
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
          label: 'Hauteur manométrique (m) *',
          hint: 'Ex: 50',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _hoursPerDayFlowController,
          label: 'Heures de fonctionnement par jour *',
          hint: 'Ex: 8',
        ),
      ],
    );
  }

  Widget _buildAreaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Surface *',
          style: TextStyle(
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
                    return 'Requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nombre invalide';
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
                    hint: const Text('Unité'),
                    items: const [
                      DropdownMenuItem(value: AreaUnit.m2, child: Text('m²')),
                      DropdownMenuItem(value: AreaUnit.ha, child: Text('ha')),
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
        const Text(
          'Type de culture *',
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
              value: _selectedCropType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: const Text('Sélectionnez une culture'),
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
        const Text(
          'Type d\'irrigation *',
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
              value: _selectedIrrigationType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              hint: const Text('Sélectionnez un type'),
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
          label: 'Heures de fonctionnement par jour *',
          hint: 'Ex: 8',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _headMetersAreaController,
          label: 'Hauteur manométrique (m) *',
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
          label: 'Volume du réservoir (m³) *',
          hint: 'Ex: 50',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _fillHoursController,
          label: 'Temps de remplissage (heures) *',
          hint: 'Ex: 4',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _wellDepthController,
          label: 'Profondeur du puits (m) *',
          hint: 'Ex: 30',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _tankHeightController,
          label: 'Hauteur du réservoir (m) *',
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
              return 'Requis';
            }
            if (double.tryParse(value) == null) {
              return 'Nombre invalide';
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
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
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
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

