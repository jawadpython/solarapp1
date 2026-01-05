import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/calculator/services/calculator_service.dart';
import 'package:noor_energy/features/calculator/services/region_service.dart';
import 'package:noor_energy/features/calculator/screens/calculator_result_screen.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:noor_energy/routes/app_routes.dart';

class CalculatorInputScreen extends StatefulWidget {
  const CalculatorInputScreen({super.key});

  @override
  State<CalculatorInputScreen> createState() => _CalculatorInputScreenState();
}

class _CalculatorInputScreenState extends State<CalculatorInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _factureDHController = TextEditingController();
  final _regionService = RegionService.instance;
  final _calculatorService = SolarCalculatorService();

  // Calculator type selector
  String _selectedCalculatorType = 'electricity'; // Default: Installation solaire

  String? _selectedSystemType;
  String? _selectedRegionCode; // Store regionCode internally
  String? _selectedUsageType;
  int? _selectedPanelWp = 550;
  bool _isCalculating = false;

  List<RegionModel> _regions = [];
  bool _isLoadingRegions = true;

  final List<String> _systemTypes = ['ON-GRID', 'HYBRID', 'OFF-GRID'];
  final List<int> _panelWpOptions = [240, 280, 300, 450, 500, 550, 600];

  @override
  void initState() {
    super.initState();
    // Default usage type - will be set to localized value when needed
    // Using null initially, will default to localized "house" in calculation
    _selectedUsageType = null;
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

  void _handleCalculatorTypeChange(String? type) {
    if (type == null) return;
    
    setState(() {
      _selectedCalculatorType = type;
    });

    // Navigate to pumping calculator if selected
    if (type == 'pumping') {
      Navigator.pushNamed(context, AppRoutes.pumpingCalculator);
      // Reset to electricity after navigation (for when user comes back)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _selectedCalculatorType = 'electricity';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _factureDHController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate required dropdowns first
    if (_selectedSystemType == null || _selectedRegionCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllFields),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get form values
    final factureDH = double.tryParse(_factureDHController.text);
    if (factureDH == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidBillAmount),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading state
    if (mounted) {
      setState(() {
        _isCalculating = true;
      });
    }

    try {
      // Calculate solar system
      final result = await _calculatorService.calculate(
        factureDH: factureDH,
        systemType: _selectedSystemType!,
        regionCode: _selectedRegionCode!,
        usageType: _selectedUsageType ?? AppLocalizations.of(context)!.house,
        panelWp: _selectedPanelWp ?? 550,
      );

      // Navigate to result screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculatorResultScreen(
              result: result,
              systemType: _selectedSystemType!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorCalculating}: $e'),
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
              
              // Calculator Type Selector
              Text(
                'Type de calcul',
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
                    child: _CalculatorTypeCard(
                      title: 'Installation solaire',
                      subtitle: '(électricité)',
                      icon: Icons.bolt,
                      isSelected: _selectedCalculatorType == 'electricity',
                      onTap: () => _handleCalculatorTypeChange('electricity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CalculatorTypeCard(
                      title: 'Pompage solaire',
                      subtitle: '',
                      icon: Icons.water_drop,
                      isSelected: _selectedCalculatorType == 'pumping',
                      onTap: () => _handleCalculatorTypeChange('pumping'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Only show electricity form fields when electricity is selected
              if (_selectedCalculatorType == 'electricity') ...[
                // A) Facture DH TextField
              Text(
                AppLocalizations.of(context)!.monthlyBillAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _factureDHController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.fillThisField;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return AppLocalizations.of(context)!.enterValidNumber;
                  }
                  if (amount <= 50) {
                    return AppLocalizations.of(context)!.amountMustBeGreater;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '500',
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
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 24),

              // B) System Type Dropdown (Required)
              Text(
                '${AppLocalizations.of(context)!.systemType} *',
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
                    hint: Text(AppLocalizations.of(context)!.selectType),
                    items: _systemTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSystemType = value);
                    },
                  ),
                ),
              ),
              if (_selectedSystemType == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    AppLocalizations.of(context)!.fillThisField,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // C) Region Dropdown (Required)
              Text(
                '${AppLocalizations.of(context)!.region} *',
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
                    AppLocalizations.of(context)!.fillThisField,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // D) Usage Type Dropdown (Optional, default = Maison)
              Text(
                AppLocalizations.of(context)!.usageType,
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
                    value: _selectedUsageType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: [
                      DropdownMenuItem(
                        value: AppLocalizations.of(context)!.house,
                        child: Text(AppLocalizations.of(context)!.house),
                      ),
                      DropdownMenuItem(
                        value: AppLocalizations.of(context)!.commerce,
                        child: Text(AppLocalizations.of(context)!.commerce),
                      ),
                      DropdownMenuItem(
                        value: AppLocalizations.of(context)!.industry,
                        child: Text(AppLocalizations.of(context)!.industry),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedUsageType = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // E) Panel WP Dropdown (Optional, default = 550)
              Text(
                AppLocalizations.of(context)!.panelPower,
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
                  child: DropdownButton<int>(
                    value: _selectedPanelWp,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _panelWpOptions.map((wp) {
                      return DropdownMenuItem(
                        value: wp,
                        child: Text('$wp W'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPanelWp = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CTA Button: Calculer
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
                          style: TextStyle(
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
}

// Calculator Type Card Widget
class _CalculatorTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalculatorTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
