import 'package:flutter/material.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/firestore_service.dart';

class TechnicianRegistrationScreen extends StatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  State<TechnicianRegistrationScreen> createState() => _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState extends State<TechnicianRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _villeController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _certificatesController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update form state when fields change
    _nomController.addListener(_onFieldChanged);
    _prenomController.addListener(_onFieldChanged);
    _villeController.addListener(_onFieldChanged);
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
    _villeController.removeListener(_onFieldChanged);
    _telephoneController.removeListener(_onFieldChanged);
    _specialiteController.removeListener(_onFieldChanged);
    _nomController.dispose();
    _prenomController.dispose();
    _villeController.dispose();
    _telephoneController.dispose();
    _specialiteController.dispose();
    _certificatesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nomController.text.trim().isNotEmpty &&
        _prenomController.text.trim().isNotEmpty &&
        _villeController.text.trim().isNotEmpty &&
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

    setState(() => _isSubmitting = true);

    try {
      String? userId;
      try {
        userId = FirebaseAuth.instance.currentUser?.uid;
      } catch (e) {
        // Continue without userId
      }

      await _firestoreService.saveTechnicianApplication(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        ville: _villeController.text.trim(),
        telephone: _telephoneController.text.trim(),
        specialite: _specialiteController.text.trim(),
        userId: userId,
        certificates: _certificatesController.text.trim().isNotEmpty 
            ? _certificatesController.text.trim() 
            : null,
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
                AppLocalizations.of(context)!.requestSent,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Votre demande d\'inscription a été envoyée avec succès. Nous vous contacterons bientôt.',
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
    _villeController.clear();
    _telephoneController.clear();
    _specialiteController.clear();
    _certificatesController.clear();
    _formKey.currentState?.reset();
  }

  void _uploadCertificates() {
    // Firebase Storage temporarily disabled - billing not enabled
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.uploadDisabled),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(localizations.becomeTechnician),
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
              // Nom
              _SectionCard(
                title: localizations.lastName,
                isRequired: true,
                child: TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: '${localizations.lastName} *',
                    hintText: 'Ex: Alami',
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
                    hintText: 'Ex: Ahmed',
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
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
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
                child: TextFormField(
                  controller: _villeController,
                  decoration: InputDecoration(
                    labelText: '${localizations.city} *',
                    hintText: localizations.cityHint,
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
                    prefixIcon: const Icon(Icons.build),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre spécialité';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Certificates (Optional for now)
              _SectionCard(
                title: localizations.certificates,
                isRequired: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _certificatesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '${localizations.certificates} (optionnel)',
                        hintText: 'URLs des certificats (sera activé plus tard)',
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
                        prefixIcon: const Icon(Icons.school),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploadCertificates,
                      icon: const Icon(Icons.upload_file),
                      label: Text(localizations.uploadDocuments),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
