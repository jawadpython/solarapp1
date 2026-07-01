import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:noor_energy/core/services/city_service.dart';
import 'package:noor_energy/core/services/firestore_service.dart';
import 'package:noor_energy/core/services/storage_service.dart';
import 'package:noor_energy/core/widgets/city_picker_field.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  State<PartnerRegistrationScreen> createState() => _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomEntrepriseController = TextEditingController();
  final _iceController = TextEditingController();
  final _ifController = TextEditingController();
  final _rcController = TextEditingController();
  final _patenteController = TextEditingController();
  final _adresseController = TextEditingController();
  final _otherCityController = TextEditingController();
  String? _selectedCityId;
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentsController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSubmitting = false;
  String _partnerServiceType = PartnerServiceTypes.canonicalLabels.first;
  final List<PlatformFile> _documentFiles = [];
  bool _isUploadingDocuments = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    CityService.instance.ensureLoaded();
    // Add listeners to update form state when fields change
    _nomEntrepriseController.addListener(_onFieldChanged);
    _iceController.addListener(_onFieldChanged);
    _ifController.addListener(_onFieldChanged);
    _rcController.addListener(_onFieldChanged);
    _patenteController.addListener(_onFieldChanged);
    _adresseController.addListener(_onFieldChanged);
    _otherCityController.addListener(_onFieldChanged);
    _telephoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {}); // Trigger rebuild to update button state
  }

  @override
  void dispose() {
    _nomEntrepriseController.removeListener(_onFieldChanged);
    _iceController.removeListener(_onFieldChanged);
    _ifController.removeListener(_onFieldChanged);
    _rcController.removeListener(_onFieldChanged);
    _patenteController.removeListener(_onFieldChanged);
    _adresseController.removeListener(_onFieldChanged);
    _otherCityController.removeListener(_onFieldChanged);
    _telephoneController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _nomEntrepriseController.dispose();
    _iceController.dispose();
    _ifController.dispose();
    _rcController.dispose();
    _patenteController.dispose();
    _adresseController.dispose();
    _otherCityController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _documentsController.dispose();
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
    return _nomEntrepriseController.text.trim().isNotEmpty &&
        _iceController.text.trim().isNotEmpty &&
        _ifController.text.trim().isNotEmpty &&
        _rcController.text.trim().isNotEmpty &&
        _patenteController.text.trim().isNotEmpty &&
        _adresseController.text.trim().isNotEmpty &&
        _isCityValid &&
        _telephoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
    // documentsEntreprise is optional for now
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

    setState(() => _isSubmitting = true);
    setState(() {
      _isUploadingDocuments = _documentFiles.isNotEmpty;
      _uploadProgress = 0;
    });

    try {
      String? userId;
      try {
        userId = FirebaseAuth.instance.currentUser?.uid;
      } catch (e) {
        // Continue without userId
      }

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> documentUrls = [];
      if (_documentFiles.isNotEmpty) {
        documentUrls = await _uploadPartnerDocuments(orderId);
      }

      await CityService.instance.ensureLoaded();
      if (!mounted) return;
      final ville = _resolveVilleForSubmit(context);
      final cityFields = CityService.instance.resolveCityFields(
        ville: ville,
        cityId: _resolveCityIdForSubmit(),
      );

      await _firestoreService.savePartnerApplication(
        nomEntreprise: _nomEntrepriseController.text.trim(),
        ice: _iceController.text.trim(),
        ifCode: _ifController.text.trim(),
        rc: _rcController.text.trim(),
        patente: _patenteController.text.trim(),
        adresse: _adresseController.text.trim(),
        ville: cityFields['ville']!,
        cityId: cityFields['cityId'],
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        speciality: _partnerServiceType,
        userId: userId,
        documentsEntreprise: _documentsController.text.trim().isNotEmpty 
            ? _documentsController.text.trim() 
            : null,
        documentsEntrepriseUrls: documentUrls.isNotEmpty ? documentUrls : null,
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
        setState(() => _isSubmitting = false);
        setState(() => _isUploadingDocuments = false);
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
          AppLocalizations.of(context)!.partnershipSentSuccess,
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
    _nomEntrepriseController.clear();
    _iceController.clear();
    _ifController.clear();
    _rcController.clear();
    _patenteController.clear();
    _adresseController.clear();
    _otherCityController.clear();
    _selectedCityId = null;
    _telephoneController.clear();
    _emailController.clear();
    _documentsController.clear();
    _documentFiles.clear();
    _isUploadingDocuments = false;
    _uploadProgress = 0;
    setState(() => _partnerServiceType = PartnerServiceTypes.canonicalLabels.first);
    _formKey.currentState?.reset();
  }

  Future<void> _pickPartnerDocuments() async {
    final files = await StorageService.instance.pickPartnerDocuments();
    if (files.isNotEmpty) {
      setState(() {
        _documentFiles.addAll(files);
      });
    }
  }

  void _removePartnerDocument(int index) {
    setState(() {
      _documentFiles.removeAt(index);
    });
  }

  bool _isImageDocument(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  Future<List<String>> _uploadPartnerDocuments(String orderId) async {
    final uploaded = <String>[];
    final total = _documentFiles.length;
    for (int i = 0; i < total; i++) {
      final file = _documentFiles[i];
      final path = StorageService.instance.generateUploadPath(
        'partner_documents/$orderId',
        file.name,
      );
      final baseProgress = i / total;
      final url = await StorageService.instance.uploadPlatformFile(
        file: file,
        path: path,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = baseProgress + (progress / total);
            });
          }
        },
      );
      if (url != null && url.isNotEmpty) {
        uploaded.add(url);
      }
    }
    return uploaded;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.becomePartner),
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
              // Nom Entreprise
              _SectionCard(
                title: localizations.companyName,
                isRequired: true,
                child: TextFormField(
                  controller: _nomEntrepriseController,
                  decoration: InputDecoration(
                    labelText: '${localizations.companyName} *',
                    hintText: localizations.enterCompanyName,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterCompanyName;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ICE
              _SectionCard(
                title: localizations.ice,
                isRequired: true,
                child: TextFormField(
                  controller: _iceController,
                  decoration: InputDecoration(
                    labelText: '${localizations.ice} *',
                    hintText: localizations.exampleIce,
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
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterIce;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // IF
              _SectionCard(
                title: localizations.ifCode,
                isRequired: true,
                child: TextFormField(
                  controller: _ifController,
                  decoration: InputDecoration(
                    labelText: '${localizations.ifCode} *',
                    hintText: localizations.exampleIf,
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
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterIf;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // RC
              _SectionCard(
                title: localizations.rc,
                isRequired: true,
                child: TextFormField(
                  controller: _rcController,
                  decoration: InputDecoration(
                    labelText: '${localizations.rc} *',
                    hintText: localizations.exampleRc,
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
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterRc;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Patente
              _SectionCard(
                title: localizations.patente,
                isRequired: true,
                child: TextFormField(
                  controller: _patenteController,
                  decoration: InputDecoration(
                    labelText: '${localizations.patente} *',
                    hintText: localizations.examplePatente,
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
                    prefixIcon: const Icon(Icons.verified),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterPatente;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Adresse
              _SectionCard(
                title: localizations.address,
                isRequired: true,
                child: TextFormField(
                  controller: _adresseController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '${localizations.address} *',
                    hintText: localizations.exampleAddress,
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
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterAddress;
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

              // Type de service
              _SectionCard(
                title: localizations.serviceType,
                isRequired: true,
                child: DropdownButtonFormField<String>(
                  key: ValueKey<String>(_partnerServiceType),
                  initialValue: _partnerServiceType,
                  decoration: InputDecoration(
                    labelText: '${localizations.serviceType} *',
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
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: PartnerServiceTypes.canonicalLabels
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _partnerServiceType = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterSpecialty;
                    }
                    return null;
                  },
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
                    hintText: localizations.phoneHintPartner,
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

              // Email
              _SectionCard(
                title: localizations.email,
                isRequired: true,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '${localizations.email} *',
                    hintText: localizations.emailHint,
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
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.validationPleaseEnterEmailPartner;
                    }
                    if (!value.contains('@')) {
                      return localizations.enterValidEmail;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Documents Entreprise (upload files: images/pdf)
              _SectionCard(
                title: localizations.companyDocuments,
                isRequired: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _documentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: localizations.companyDocumentsOptional,
                        hintText: localizations.documentsUrlsComingSoon,
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
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickPartnerDocuments,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 36,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Uploader images/PDF',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_documentFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _documentFiles.length,
                        itemBuilder: (context, index) {
                          final file = _documentFiles[index];
                          final isImage = _isImageDocument(file.name);
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isImage ? Icons.image : Icons.picture_as_pdf,
                              color: isImage ? Colors.blue : Colors.red,
                            ),
                            title: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removePartnerDocument(index),
                            ),
                          );
                        },
                      ),
                      Text(
                        '${_documentFiles.length} fichier(s) sélectionné(s)',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_isUploadingDocuments) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Upload... ${(_uploadProgress * 100).toInt()}%',
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
