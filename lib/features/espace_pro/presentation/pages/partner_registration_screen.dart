import 'package:flutter/material.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/firestore_service.dart';

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
  final _villeController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentsController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update form state when fields change
    _nomEntrepriseController.addListener(_onFieldChanged);
    _iceController.addListener(_onFieldChanged);
    _ifController.addListener(_onFieldChanged);
    _rcController.addListener(_onFieldChanged);
    _patenteController.addListener(_onFieldChanged);
    _adresseController.addListener(_onFieldChanged);
    _villeController.addListener(_onFieldChanged);
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
    _villeController.removeListener(_onFieldChanged);
    _telephoneController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _nomEntrepriseController.dispose();
    _iceController.dispose();
    _ifController.dispose();
    _rcController.dispose();
    _patenteController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _documentsController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nomEntrepriseController.text.trim().isNotEmpty &&
        _iceController.text.trim().isNotEmpty &&
        _ifController.text.trim().isNotEmpty &&
        _rcController.text.trim().isNotEmpty &&
        _patenteController.text.trim().isNotEmpty &&
        _adresseController.text.trim().isNotEmpty &&
        _villeController.text.trim().isNotEmpty &&
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
          const SnackBar(
            content: Text('Erreur: Firebase n\'est pas initialisé. Veuillez configurer Firebase.'),
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

      await _firestoreService.savePartnerApplication(
        nomEntreprise: _nomEntrepriseController.text.trim(),
        ice: _iceController.text.trim(),
        ifCode: _ifController.text.trim(),
        rc: _rcController.text.trim(),
        patente: _patenteController.text.trim(),
        adresse: _adresseController.text.trim(),
        ville: _villeController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        userId: userId,
        documentsEntreprise: _documentsController.text.trim().isNotEmpty 
            ? _documentsController.text.trim() 
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
          'Votre demande de partenariat a été envoyée avec succès. Nous vous contacterons bientôt.',
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
    _villeController.clear();
    _telephoneController.clear();
    _emailController.clear();
    _documentsController.clear();
    _formKey.currentState?.reset();
  }

  void _uploadDocuments() {
    // Firebase Storage temporarily disabled - billing not enabled
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upload temporarily disabled. Feature will be activated soon 👍'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(localizations.becomePartner),
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
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de l\'entreprise';
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
                    hintText: 'Ex: 123456789012345',
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
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'ICE';
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
                    hintText: 'Ex: 12345678',
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
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'IF';
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
                    hintText: 'Ex: 12345',
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
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le RC';
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
                    hintText: 'Ex: 123456',
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
                    prefixIcon: const Icon(Icons.verified),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la Patente';
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
                    hintText: 'Ex: 123 Rue Example, Quartier...',
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
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'adresse';
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
                    hintText: localizations.cityHintPartner,
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
                    hintText: localizations.phoneHintPartner,
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
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Documents Entreprise (Optional for now)
              _SectionCard(
                title: localizations.companyDocuments,
                isRequired: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _documentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '${localizations.companyDocuments} (optionnel)',
                        hintText: 'URLs des documents (sera activé plus tard)',
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
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _uploadDocuments,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Téléverser des documents'),
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
