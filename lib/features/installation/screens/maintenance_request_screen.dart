import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/firestore_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  const MaintenanceRequestScreen({super.key});

  @override
  State<MaintenanceRequestScreen> createState() => _MaintenanceRequestScreenState();
}

class _MaintenanceRequestScreenState extends State<MaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSubmitting = false;
  String? _selectedUrgency;

  List<String> _selectedMedia = [];

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validation state when text changes
    _descriptionController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
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
    _descriptionController.removeListener(_onFieldChanged);
    _locationController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _cityController.removeListener(_onFieldChanged);
    _descriptionController.dispose();
    _locationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _cityController.text.isNotEmpty;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.firebaseNotInitialized),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? userId;
      try {
        userId = FirebaseAuth.instance.currentUser?.uid;
      } catch (e) {
        // Continue without userId
      }

      await _firestoreService.saveMaintenanceRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        urgency: _selectedUrgency,
        userId: userId,
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
                AppLocalizations.of(context)!.success,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.success,
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
    _descriptionController.clear();
    _locationController.clear();
    _nameController.clear();
    _phoneController.clear();
    _cityController.clear();
    setState(() {
      _selectedUrgency = null;
      _selectedMedia = [];
    });
  }


  void _pickMedia() {
    // TODO: Implement media picker (photo/video)
    setState(() {
      _selectedMedia.add('media_${_selectedMedia.length + 1}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.mediaAdded)),
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _callTechnician() {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.callFeatureComing)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.maintenanceRequest),
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
              // Section 1: Personal Info
              _SectionCard(
                title: AppLocalizations.of(context)!.personalInfo,
                isRequired: true,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fullNameLabel,
                        hintText: AppLocalizations.of(context)!.nameHint,
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
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Téléphone *',
                        hintText: AppLocalizations.of(context)!.phoneHint,
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
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Ville *',
                        hintText: AppLocalizations.of(context)!.cityHint,
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
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre ville';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Section 2: Describe Issue
              _SectionCard(
                title: AppLocalizations.of(context)!.describeProblem,
                isRequired: true,
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.describeProblemHint,
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
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez décrire le problème';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Section 2.5: Urgency
              _SectionCard(
                title: AppLocalizations.of(context)!.urgency,
                isRequired: false,
                child: DropdownButtonFormField<String>(
                  value: _selectedUrgency,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.selectUrgency,
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
                    prefixIcon: const Icon(Icons.priority_high),
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: Text(AppLocalizations.of(context)!.urgencyLow)),
                    DropdownMenuItem(value: 'normal', child: Text(AppLocalizations.of(context)!.urgencyNormal)),
                    DropdownMenuItem(value: 'high', child: Text(AppLocalizations.of(context)!.urgencyHigh)),
                    DropdownMenuItem(value: 'urgent', child: Text(AppLocalizations.of(context)!.urgencyUrgent)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUrgency = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Add Photo/Video
              _SectionCard(
                title: AppLocalizations.of(context)!.addPhotoVideo,
                isRequired: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedMedia.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun média sélectionné',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(_selectedMedia.length, (index) {
                          final isVideo = _selectedMedia[index].contains('video');
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Icon(
                                  isVideo ? Icons.videocam : Icons.image,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              if (isVideo)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: IconButton(
                                  icon: Container(
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
                                  onPressed: () => _removeMedia(index),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickMedia,
                            icon: const Icon(Icons.photo_library),
                            label: Text(AppLocalizations.of(context)!.photo),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickMedia,
                            icon: const Icon(Icons.videocam),
                            label: Text(AppLocalizations.of(context)!.video),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: GPS Location - Manual Entry
              _SectionCard(
                title: AppLocalizations.of(context)!.gpsLocation,
                isRequired: true,
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.addressGps,
                    hintText: AppLocalizations.of(context)!.cityHint,
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
                    prefixIcon: const Icon(Icons.location_city),
                    helperText: 'Entrez votre adresse ou coordonnées GPS manuellement',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre adresse ou localisation';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isSubmitting) ? _submitRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
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
                          AppLocalizations.of(context)!.submit,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Optional Call Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _callTechnician,
                  icon: const Icon(Icons.phone),
                  label: Text(AppLocalizations.of(context)!.callFeatureComing),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
