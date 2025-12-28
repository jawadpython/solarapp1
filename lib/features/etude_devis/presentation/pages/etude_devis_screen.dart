import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/routes/app_routes.dart';

class EtudeDevisScreen extends StatefulWidget {
  const EtudeDevisScreen({super.key});

  @override
  State<EtudeDevisScreen> createState() => _EtudeDevisScreenState();
}

class _EtudeDevisScreenState extends State<EtudeDevisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _consumptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedSystemType;
  String? _consumptionMethod;
  String? _selectedFile;

  final List<String> _systemTypes = ['On-grid', 'Off-grid', 'Hybride', 'Pompe'];

  @override
  void dispose() {
    _consumptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedSystemType != null &&
        _consumptionMethod != null &&
        _locationController.text.isNotEmpty &&
        // File upload temporarily disabled - removed from validation
        // Form is valid if: method is 'Entrer kWh' with filled consumption, OR method is 'Télécharger facture' (file optional now)
        (_consumptionMethod == 'Entrer kWh' 
            ? _consumptionController.text.isNotEmpty
            : true); // 'Télécharger facture' method allowed but file upload disabled
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      // TODO: Save to Firebase
      _showSuccessDialog();
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
            const Expanded(
              child: Text(
                'Demande envoyée',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Votre demande de devis a été envoyée avec succès. Nous vous contacterons bientôt.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Demande de devis'),
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
              // Section 1: System Type
              _SectionCard(
                title: 'Type de système',
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

              // Section 2: Consumption Input
              _SectionCard(
                title: 'Consommation',
                isRequired: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radio buttons for consumption method
                    _RadioOption(
                      value: 'Entrer kWh',
                      groupValue: _consumptionMethod,
                      onChanged: (value) {
                        setState(() {
                          _consumptionMethod = value;
                          _selectedFile = null;
                        });
                      },
                    ),
                    _RadioOption(
                      value: 'Télécharger facture',
                      groupValue: _consumptionMethod,
                      onChanged: (value) {
                        setState(() {
                          _consumptionMethod = value;
                          _consumptionController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Conditional field for kWh input
                    if (_consumptionMethod == 'Entrer kWh')
                      TextFormField(
                        controller: _consumptionController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Consommation (kWh)',
                          hintText: 'Ex: 500',
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
                          prefixIcon: const Icon(Icons.bolt),
                        ),
                        validator: (value) {
                          if (_consumptionMethod == 'Entrer kWh' &&
                              (value == null || value.isEmpty)) {
                            return 'Veuillez entrer la consommation';
                          }
                          return null;
                        },
                      ),
                    // File upload section
                    if (_consumptionMethod == 'Télécharger facture') ...[
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
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFile ?? 'Aucun fichier sélectionné',
                              style: TextStyle(
                                color: _selectedFile != null ? Colors.black87 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                // Firebase Storage temporarily disabled - billing not enabled
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Upload temporarily disabled. Feature will be activated soon 👍'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Choisir une facture'),
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
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: GPS Location
              _SectionCard(
                title: 'Localisation GPS',
                isRequired: true,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Get GPS location
                          setState(() {
                            _locationController.text = 'Position GPS capturée';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Position GPS capturée')),
                          );
                        },
                        icon: const Icon(Icons.location_on),
                        label: const Text('Utiliser ma position'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Adresse / Coordonnées GPS',
                        hintText: 'Cliquez sur "Utiliser ma position"',
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
                          return 'Veuillez capturer votre position GPS';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Financing Option
              _SectionCard(
                title: 'Option Financement',
                isRequired: false,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.financingForm);
                    },
                    icon: const Icon(Icons.account_balance),
                    label: const Text('Accéder au formulaire de financement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _submitRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Demander un devis',
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
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: groupValue == value
                ? AppColors.primary
                : Colors.grey.shade300,
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

