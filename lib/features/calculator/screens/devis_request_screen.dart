import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/widgets/success_dialog.dart';
import 'package:noor_energy/features/calculator/models/devis_request.dart';
import 'package:noor_energy/features/calculator/models/solar_result.dart';
import 'package:noor_energy/features/calculator/services/devis_service.dart';
import 'package:noor_energy/routes/app_routes.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class DevisRequestScreen extends StatefulWidget {
  final SolarResult result;
  final String systemType;
  final String? initialNote;

  const DevisRequestScreen({
    super.key,
    required this.result,
    required this.systemType,
    this.initialNote,
  });

  @override
  State<DevisRequestScreen> createState() => _DevisRequestScreenState();
}

class _DevisRequestScreenState extends State<DevisRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _gpsController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill note field if initialNote is provided
    if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
      _noteController.text = widget.initialNote!;
    }
    // Add listeners to update form validation state when text changes
    _fullNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild to update form validation state
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _cityController.removeListener(_onFieldChanged);
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _gpsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    print('🔘🔘🔘 SUBMIT BUTTON CLICKED! 🔘🔘🔘');
    debugPrint('🔘 Submit button clicked!');
    developer.log('Submit button clicked', name: 'DevisRequestScreen');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed!');
      debugPrint('❌ Form validation failed!');
      return;
    }
    
    print('✅ Form validation passed!');
    debugPrint('✅ Form validation passed!');

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('🚀🚀🚀 Starting devis request submission... 🚀🚀🚀');
      debugPrint('🚀 Starting devis request submission...');
      developer.log('Starting devis request submission', name: 'DevisRequestScreen');
      
      final request = DevisRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        gps: _gpsController.text.trim().isEmpty
            ? null
            : _gpsController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        factureImagePath: null, // Not implemented yet
        systemType: widget.systemType,
        regionCode: widget.result.regionCode,
        kwhMonth: widget.result.kwhMonth,
        powerKW: widget.result.powerKW,
        panels: widget.result.panels,
        savingsMonth: widget.result.savingMonth,
        savingsYear: widget.result.savingYear,
      );

      print('📝 Request object created: ${request.fullName}, ${request.phone}, ${request.city}');
      print('💾 Calling DevisService.saveRequest...');
      debugPrint('📝 Request object created: ${request.fullName}, ${request.phone}, ${request.city}');
      debugPrint('💾 Calling DevisService.saveRequest...');
      
      await DevisService.saveRequest(request);

      print('✅✅✅ DevisService.saveRequest completed successfully! ✅✅✅');
      debugPrint('✅ DevisService.saveRequest completed successfully!');
      
      if (mounted) {
        _clearForm();
        final loc = AppLocalizations.of(context)!;
        showSuccessDialog(
          context,
          title: loc.success,
          message: loc.devisRequestSentSuccess,
          onDone: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.homeScreen,
              (route) => false,
            );
          },
        );
      }
    } catch (e, stackTrace) {
      print('❌❌❌ ERROR in _submitRequest: $e ❌❌❌');
      print('📋 Stack trace: $stackTrace');
      debugPrint('❌ ERROR in _submitRequest: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      developer.log('ERROR in _submitRequest', error: e, stackTrace: stackTrace, name: 'DevisRequestScreen');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorSending}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.errorDetails,
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.errorDetails),
                    content: SingleChildScrollView(
                      child: Text('$e\n\n$stackTrace'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _fullNameController.clear();
    _phoneController.clear();
    _cityController.clear();
    _gpsController.clear();
    _noteController.clear();
  }


  bool get _isFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.requestQuote),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
              // Read-only Technical Data Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.technicalData,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: AppLocalizations.of(context)!.systemTypeLabel,
                      value: widget.systemType,
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: AppLocalizations.of(context)!.regionCode,
                      value: result.regionCode,
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: AppLocalizations.of(context)!.consumptionKwhMonth,
                      value: '${result.kwhMonth.toStringAsFixed(1)} kWh',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: AppLocalizations.of(context)!.recommendedPower,
                      value: '${result.powerKW.toStringAsFixed(2)} kW',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: AppLocalizations.of(context)!.numberOfPanels,
                      value: '${result.panels}',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: '${AppLocalizations.of(context)!.savings} ${AppLocalizations.of(context)!.monthly.toLowerCase()}',
                      value: '${result.savingMonth.toStringAsFixed(2)} DH',
                    ),
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: '${AppLocalizations.of(context)!.savings} ${AppLocalizations.of(context)!.yearly.toLowerCase()}',
                      value: '${result.savingYear.toStringAsFixed(2)} DH',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // User Input Section
              Text(
                AppLocalizations.of(context)!.contactInfo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              // Full Name
              Text(
                AppLocalizations.of(context)!.fullNameLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.fillThisField;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.nameHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              // Phone
              Text(
                AppLocalizations.of(context)!.phoneLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.fillThisField;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.phoneHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              // City
              Text(
                AppLocalizations.of(context)!.cityLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.fillThisField;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.cityHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 20),
              // Address (Optional) - Manual Entry
              Text(
                AppLocalizations.of(context)!.addressOptional,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gpsController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterAddressManually,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  helperText: AppLocalizations.of(context)!.enterAddressManually,
                ),
              ),
              const SizedBox(height: 20),
              // Note (Optional)
              Text(
                AppLocalizations.of(context)!.noteOptional,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.addAdditionalInfo,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isSubmitting) ? _submitRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colorScheme.outline,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.sendRequest,
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
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

