import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/city_service.dart';
import 'package:noor_energy/core/services/firestore_service.dart';
import 'package:noor_energy/core/services/storage_service.dart';
import 'package:noor_energy/core/widgets/city_picker_field.dart';

class TechnicianRegistrationScreen extends StatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  State<TechnicianRegistrationScreen> createState() => _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState extends State<TechnicianRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _otherCityController = TextEditingController();
  String? _selectedCityId;
  final _telephoneController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _certificatesController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSubmitting = false;
  
  // Certificate images
  final List<XFile> _certificateImages = [];
  final List<Uint8List> _certificateImageBytes = [];
  bool _isUploadingImages = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    CityService.instance.ensureLoaded();
    // Add listeners to update form state when fields change
    _nomController.addListener(_onFieldChanged);
    _prenomController.addListener(_onFieldChanged);
    _otherCityController.addListener(_onFieldChanged);
    _telephoneController.addListener(_onFieldChanged);
    _specialiteController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  @override
  void dispose() {
    _nomController.removeListener(_onFieldChanged);
    _prenomController.removeListener(_onFieldChanged);
    _otherCityController.removeListener(_onFieldChanged);
    _telephoneController.removeListener(_onFieldChanged);
    _specialiteController.removeListener(_onFieldChanged);
    _nomController.dispose();
    _prenomController.dispose();
    _otherCityController.dispose();
    _telephoneController.dispose();
    _specialiteController.dispose();
    _certificatesController.dispose();
    super.dispose();
  }

  bool get _isCityValid {
    if (_selectedCityId == null || _selectedCityId!.isEmpty) return false;
    if (_selectedCityId == CityService.otherCityId) {
      return _otherCityController.text.trim().isNotEmpty;
    }
    return true;
  }

  String _resolveVilleForSubmit(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (_selectedCityId == CityService.otherCityId) {
      return _otherCityController.text.trim();
    }
    return CityService.instance.getDisplayName(_selectedCityId!, locale);
  }

  String? _resolveCityIdForSubmit() {
    if (_selectedCityId == null || _selectedCityId == CityService.otherCityId) {
      return null;
    }
    return _selectedCityId;
  }

  bool get _isFormValid {
    return _nomController.text.trim().isNotEmpty &&
        _prenomController.text.trim().isNotEmpty &&
        _isCityValid &&
        _telephoneController.text.trim().isNotEmpty &&
        _specialiteController.text.trim().isNotEmpty;
    // certificates is optional for now
  }

  Future<void> _submitForm() async {
    // Prevent double submission
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.firebaseNotInitialized),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isUploadingImages = _certificateImages.isNotEmpty;
    });

    try {
      String? userId;
      try {
        userId = FirebaseAuth.instance.currentUser?.uid;
      } catch (e) {
        // Continue without userId
      }

      // Generate a unique order ID for this application
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload certificate images if any
      List<String> certificateUrls = [];
      if (_certificateImages.isNotEmpty) {
        certificateUrls = await _uploadCertificateImages(orderId);
      }

      setState(() => _isUploadingImages = false);

      await CityService.instance.ensureLoaded();
      if (!mounted) return;
      final ville = _resolveVilleForSubmit(context);
      final cityFields = CityService.instance.resolveCityFields(
        ville: ville,
        cityId: _resolveCityIdForSubmit(),
      );

      await _firestoreService.saveTechnicianApplication(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        ville: cityFields['ville']!,
        cityId: cityFields['cityId'],
        telephone: _telephoneController.text.trim(),
        specialite: _specialiteController.text.trim(),
        userId: userId,
        certificates: _certificatesController.text.trim().isNotEmpty 
            ? _certificatesController.text.trim() 
            : null,
        certificateUrls: certificateUrls.isNotEmpty ? certificateUrls : null,
      );

      if (mounted) {
        _clearForm();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImages = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.requestSent,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.registrationSentSuccess,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nomController.clear();
    _prenomController.clear();
    _otherCityController.clear();
    _selectedCityId = null;
    _telephoneController.clear();
    _specialiteController.clear();
    _certificatesController.clear();
    _certificateImages.clear();
    _certificateImageBytes.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _pickCertificateImage() async {
    final images = await StorageService.instance.pickMultipleImages();
    if (images.isNotEmpty) {
      for (final image in images) {
        final bytes = await image.readAsBytes();
        setState(() {
          _certificateImages.add(image);
          _certificateImageBytes.add(bytes);
        });
      }
    }
  }

  void _removeCertificateImage(int index) {
    setState(() {
      _certificateImages.removeAt(index);
      _certificateImageBytes.removeAt(index);
    });
  }

  Future<List<String>> _uploadCertificateImages(String orderId) async {
    final List<String> uploadedUrls = [];
    final int totalImages = _certificateImages.length;
    
    for (int i = 0; i < totalImages; i++) {
      final image = _certificateImages[i];
      final path = StorageService.instance.generateUploadPath(
        'technician_certificates/$orderId',
        image.name,
      );
      
      // Update progress: each image contributes equally to total progress
      final baseProgress = i / totalImages;
      
      final url = await StorageService.instance.uploadImage(
        file: image,
        path: path,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              // Progress = completed images + current image progress
              _uploadProgress = baseProgress + (progress / totalImages);
            });
          }
        },
      );
      
      if (url != null) {
        uploadedUrls.add(url);
        debugPrint('Certificate image ${i + 1}/$totalImages uploaded: $url');
      } else {
        debugPrint('Failed to upload certificate image ${i + 1}/$totalImages');
      }
    }
    
    return uploadedUrls;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.becomeTechnician),
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
              // Nom
              _SectionCard(
                title: localizations.lastName,
                isRequired: true,
                child: TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: '${localizations.lastName} *',
                    hintText: localizations.exampleLastName,
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
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterLastName;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Prénom
              _SectionCard(
                title: localizations.firstName,
                isRequired: true,
                child: TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(
                    labelText: '${localizations.firstName} *',
                    hintText: localizations.exampleFirstName,
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
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterFirstName;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Ville
              _SectionCard(
                title: localizations.city,
                isRequired: true,
                child: CityPickerField(
                  selectedCityId: _selectedCityId,
                  otherCityController: _otherCityController,
                  fillColor: colorScheme.surfaceContainerHighest,
                  outlineColor: colorScheme.outline,
                  onCityIdChanged: (value) {
                    setState(() => _selectedCityId = value);
                  },
                  onChanged: _onFieldChanged,
                ),
              ),
              const SizedBox(height: 20),

              // Téléphone
              _SectionCard(
                title: localizations.phone,
                isRequired: true,
                child: TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '${localizations.phone} *',
                    hintText: localizations.phoneHint,
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
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterPhone;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Spécialité
              _SectionCard(
                title: localizations.specialty,
                isRequired: true,
                child: TextFormField(
                  controller: _specialiteController,
                  decoration: InputDecoration(
                    labelText: '${localizations.specialty} *',
                    hintText: localizations.specialtyHint,
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
                    prefixIcon: const Icon(Icons.build),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterSpecialty;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Certificates Upload
              _SectionCard(
                title: localizations.certificates,
                isRequired: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Certificate description field
                    TextFormField(
                      controller: _certificatesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: localizations.certificatesOptional,
                        hintText: localizations.certificatesHint,
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
                        prefixIcon: const Icon(Icons.school),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Upload button
                    Text(
                      localizations.uploadCertificateImages,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickCertificateImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.tapToUploadCertificates,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Image previews
                    if (_certificateImageBytes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _certificateImageBytes.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _certificateImageBytes[index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeCertificateImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_certificateImageBytes.length} ${localizations.imagesSelected}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    // Upload progress
                    if (_isUploadingImages) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${localizations.uploading}... ${(_uploadProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isSubmitting) ? _submitForm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colorScheme.outline,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
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
                          localizations.submit,
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
