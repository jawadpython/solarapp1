import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

class InstallationRequestScreen extends StatefulWidget {
  const InstallationRequestScreen({super.key});

  @override
  State<InstallationRequestScreen> createState() => _InstallationRequestScreenState();
}

class _InstallationRequestScreenState extends State<InstallationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyAmountController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSystemType;
  String? _selectedPlaceType;
  String? _selectedObjective;
  String? _selectedEstimationMethod;
  String? _selectedFile;

  final List<String> _systemTypes = ['On-Grid', 'Off-Grid', 'Hybride', 'Pompage solaire'];
  final List<String> _placeTypes = ['Maison', 'Commerce', 'Entreprise', 'Exploitation agricole'];
  final List<String> _objectives = [
    'Réduire la facture d\'électricité',
    'Indépendance énergétique',
    'Alimenter des équipements',
    'Pompage d\'eau'
  ];
  final List<String> _estimationMethods = [
    'Télécharger une facture',
    'Saisir le montant mensuel',
    'Je ne sais pas'
  ];

  @override
  void dispose() {
    _monthlyAmountController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSystemTypeChange(String? value) {
    setState(() {
      _selectedSystemType = value;
      // Auto-select "Pompage d'eau" if "Pompage solaire" is selected
      if (value == 'Pompage solaire') {
        _selectedObjective = 'Pompage d\'eau';
      }
    });
  }

  bool get _isFormValid {
    return _selectedSystemType != null &&
        _selectedPlaceType != null &&
        _selectedObjective != null &&
        _selectedEstimationMethod != null &&
        _cityController.text.isNotEmpty &&
        (_selectedEstimationMethod != 'Saisir le montant mensuel' ||
            _monthlyAmountController.text.isNotEmpty);
  }

  void _submitForm() {
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
          'Votre demande d\'installation a été envoyée avec succès.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        title: const Text('Demande d\'installation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Type de système
              _SectionCard(
                title: 'Type de système',
                isRequired: true,
                child: Column(
                  children: _systemTypes.map((type) => _RadioOption(
                        value: type,
                        groupValue: _selectedSystemType,
                        onChanged: _handleSystemTypeChange,
                      )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Section 2: Type de lieu
              _SectionCard(
                title: 'Type de lieu',
                isRequired: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPlaceType,
                      isExpanded: true,
                      hint: const Text('Sélectionnez le type de lieu'),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _placeTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlaceType = value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Objectif du système
              _SectionCard(
                title: 'Objectif du système',
                isRequired: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedObjective,
                      isExpanded: true,
                      hint: const Text('Sélectionnez l\'objectif'),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _objectives.map((objective) {
                        return DropdownMenuItem(
                          value: objective,
                          child: Text(objective),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedObjective = value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Méthode d'estimation
              _SectionCard(
                title: 'Méthode d\'estimation de consommation',
                isRequired: true,
                child: Column(
                  children: _estimationMethods.map((method) => _RadioOption(
                        value: method,
                        groupValue: _selectedEstimationMethod,
                        onChanged: (value) {
                          setState(() => _selectedEstimationMethod = value);
                        },
                      )).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Conditional field for monthly amount
              if (_selectedEstimationMethod == 'Saisir le montant mensuel') ...[
                _SectionCard(
                  title: 'Montant mensuel',
                  isRequired: true,
                  child: TextFormField(
                    controller: _monthlyAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Montant mensuel (DH)',
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
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (_selectedEstimationMethod == 'Saisir le montant mensuel' &&
                          (value == null || value.isEmpty)) {
                        return 'Veuillez entrer le montant mensuel';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Section 5: Localisation
              _SectionCard(
                title: 'Localisation',
                isRequired: true,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Get GPS location
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonctionnalité GPS à venir')),
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
                      controller: _cityController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Ville / Région *',
                        hintText: 'Ex: Casablanca',
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
                          return 'Veuillez entrer votre ville ou région';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 6: Remarques (Optional)
              _SectionCard(
                title: 'Remarques',
                isRequired: false,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ajoutez des informations supplémentaires...',
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
                ),
              ),
              const SizedBox(height: 20),

              // Section 7: Photo upload (Optional)
              _SectionCard(
                title: 'Téléverser une photo du site',
                isRequired: false,
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
                        // TODO: Implement file picker
                        setState(() {
                          _selectedFile = 'facture.pdf'; // Placeholder
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sélection de fichier à venir')),
                        );
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choisir un fichier'),
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

              // 8. Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _submitForm : null,
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
                  child: const Text(
                    'Demander l\'installation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Note below button
              Center(
                child: Text(
                  'Estimation indicative — le devis final sera confirmé après une visite technique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
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

/// Section card widget for grouping form fields
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
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
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 6),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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

/// Radio button option widget
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
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
