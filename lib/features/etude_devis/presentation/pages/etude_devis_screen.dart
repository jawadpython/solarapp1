import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/firestore_service.dart';
import 'package:noor_energy/core/widgets/success_dialog.dart';
import 'package:noor_energy/core/services/notification_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class EtudeDevisScreen extends StatefulWidget {
  const EtudeDevisScreen({super.key});

  @override
  State<EtudeDevisScreen> createState() => _EtudeDevisScreenState();
}

class _EtudeDevisScreenState extends State<EtudeDevisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _consumptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _firestoreService = FirestoreService();

  String? _selectedSystemType;
  String? _consumptionMethod; // Defaults to enterKwh (file upload removed for now)
  bool _isSubmitting = false;

  final List<String> _systemTypes = ['On-grid', 'Off-grid', 'Hybride', 'Pompe'];

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_syncFormValidity);
    _phoneController.addListener(_syncFormValidity);
    _cityController.addListener(_syncFormValidity);
    _consumptionController.addListener(_syncFormValidity);
    _addressController.addListener(_syncFormValidity);
  }

  void _syncFormValidity() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_consumptionMethod == null) {
      _consumptionMethod = AppLocalizations.of(context)!.enterKwh;
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_syncFormValidity);
    _phoneController.removeListener(_syncFormValidity);
    _cityController.removeListener(_syncFormValidity);
    _consumptionController.removeListener(_syncFormValidity);
    _addressController.removeListener(_syncFormValidity);
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _consumptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _isFormValid(AppLocalizations loc) {
    if (_selectedSystemType == null || _consumptionMethod == null) return false;
    if (_fullNameController.text.trim().isEmpty) return false;
    if (_phoneController.text.trim().isEmpty) return false;
    if (_cityController.text.trim().isEmpty) return false;
    final consumptionText = _consumptionController.text.trim();
    if (consumptionText.isEmpty) return false;
    if (_consumptionMethod == loc.enterKwh) {
      final kwh = double.tryParse(consumptionText);
      if (kwh == null || kwh <= 0) return false;
    }
    return true;
  }

  Future<void> _submitRequest() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || !_isFormValid(loc)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();
      final city = _cityController.text.trim();
      final address = _addressController.text.trim();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Parse consumption value
      double consumption = 0.0;
      bool isKwh = _consumptionMethod == loc.enterKwh;
      
      if (isKwh) {
        consumption = double.tryParse(_consumptionController.text.trim()) ?? 0.0;
        if (consumption <= 0) {
          throw Exception(loc.invalidConsumption);
        }
      }

      // Map system type to project type
      String projectType = _selectedSystemType ?? 'On-grid';
      if (projectType == 'Pompe') {
        projectType = 'PUMPING';
      } else if (projectType == 'Hybride') {
        projectType = 'HYBRID';
      } else if (projectType == 'Off-grid') {
        projectType = 'OFF-GRID';
      } else {
        projectType = 'ON-GRID';
      }

      // Estimate power (simplified calculation - 1kW per 100kWh/month)
      double estimatedPower = isKwh ? (consumption / 100).clamp(1.0, 100.0) : 5.0;
      int panelPower = 400; // Default panel power in watts

      final requestId = await _firestoreService.saveProjectRequest(
        userId: userId,
        fullName: fullName,
        phone: phone,
        city: city,
        location: address.isNotEmpty ? address : null,
        projectType: projectType,
        consumption: consumption,
        isKwh: isKwh,
        panelPower: panelPower,
        estimatedPower: estimatedPower,
      );

      if (kDebugMode) debugPrint('✅ Étude devis saved: $requestId');

      try {
        await NotificationService().createAdminNotification(
          type: NotificationType.projectRequest,
          title: loc.newStudyDevisRequest,
          message: '$fullName ($city) — $projectType, ${isKwh ? '$consumption kWh' : 'Facture'}',
          requestId: requestId,
          requestCollection: 'project_requests',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Failed to create notification: $e');
      }

      if (mounted) {
        showSuccessDialog(
          context,
          title: loc.requestSent,
          message: loc.devisRequestSentSuccess,
          referenceNumber: requestId,
          onDone: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Étude devis error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorSending}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.quoteRequest),
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
              // Contact information
              _SectionCard(
                title: AppLocalizations.of(context)!.contactInfo,
                isRequired: true,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fullNameLabel,
                        hintText: AppLocalizations.of(context)!.nameHint,
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
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterYourName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phoneLabel,
                        hintText: AppLocalizations.of(context)!.phoneHint,
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
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterYourPhone;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.cityLabel,
                        hintText: AppLocalizations.of(context)!.cityHint,
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
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.validationPleaseEnterCity;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: System Type
              _SectionCard(
                title: AppLocalizations.of(context)!.systemTypeLabel,
                isRequired: true,
                child: Column(
                  children: _systemTypes.map((type) => _RadioOption(
                        value: type,
                        groupValue: _selectedSystemType,
                        onChanged: (value) {
                          setState(() => _selectedSystemType = value);
                        },
                      )).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Consumption Input (kWh only; file upload removed for now)
              _SectionCard(
                title: AppLocalizations.of(context)!.consumption,
                isRequired: true,
                child: TextFormField(
                  controller: _consumptionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.consumptionKwh,
                    hintText: AppLocalizations.of(context)!.consumptionExample,
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
                    prefixIcon: const Icon(Icons.bolt),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterConsumption;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Address (optional)
              _SectionCard(
                title: AppLocalizations.of(context)!.addressLabel,
                isRequired: false,
                child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.addressLabel,
                    hintText: AppLocalizations.of(context)!.enterAddressManually,
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
                    prefixIcon: const Icon(Icons.home_outlined),
                    helperText: AppLocalizations.of(context)!.enterAddressManually,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormValid(AppLocalizations.of(context)!) && !_isSubmitting)
                      ? _submitRequest
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                          AppLocalizations.of(context)!.requestFreeStudy,
                          style: TextStyle(
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isRequired;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.isRequired,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 8),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: groupValue == value
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: groupValue == value
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline,
            width: groupValue == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: groupValue == value
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

