import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  String? _selectedCity;
  String? _selectedSpeciality;
  List<Technician> _filteredTechnicians = [];

  final List<String> _cities = [
    'Tous',
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
    'Tanger',
    'Agadir',
  ];

  final List<String> _specialities = [
    'Tous',
    'Maintenance',
    'Installation',
    'Réparation',
    'Diagnostic',
    'Pompage solaire',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = 'Tous';
    _selectedSpeciality = 'Tous';
    _filteredTechnicians = _sampleTechnicians;
  }

  void _applyFilters() {
    setState(() {
      _filteredTechnicians = _sampleTechnicians.where((tech) {
        final cityMatch = _selectedCity == 'Tous' || tech.city == _selectedCity;
        final specialityMatch = _selectedSpeciality == 'Tous' || tech.speciality == _selectedSpeciality;
        return cityMatch && specialityMatch;
      }).toList();
    });
  }

  void _callTechnician(String phone) {
    // TODO: Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel vers $phone (fonctionnalité à venir)')),
    );
  }

  void _whatsappTechnician(String phone) {
    // TODO: Implement WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WhatsApp vers $phone (fonctionnalité à venir)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Techniciens Certifiés'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // City Filter
                Row(
                  children: [
                    const Icon(Icons.location_city, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Ville:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          isExpanded: true,
                          items: _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Speciality Filter
                Row(
                  children: [
                    const Icon(Icons.build_circle, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Spécialité:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSpeciality,
                          isExpanded: true,
                          items: _specialities.map((spec) {
                            return DropdownMenuItem(
                              value: spec,
                              child: Text(spec),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpeciality = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Technicians List
          Expanded(
            child: _filteredTechnicians.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun technicien trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTechnicians.length,
                    itemBuilder: (context, index) {
                      final technician = _filteredTechnicians[index];
                      return _TechnicianCard(
                        technician: technician,
                        onCall: () => _callTechnician(technician.phone),
                        onWhatsApp: () => _whatsappTechnician(technician.phone),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Sample data - Replace with actual data from backend
  static final List<Technician> _sampleTechnicians = [
    Technician(
      name: 'Ahmed Benali',
      speciality: 'Maintenance',
      city: 'Casablanca',
      phone: '+212 612 345 678',
      rating: 4.8,
      reviewCount: 24,
      availability: 'Disponible',
      serviceArea: 'Casablanca, Rabat, Settat',
      isAvailable: true,
    ),
    Technician(
      name: 'Mohamed Alami',
      speciality: 'Installation',
      city: 'Rabat',
      phone: '+212 623 456 789',
      rating: 4.9,
      reviewCount: 18,
      availability: 'Disponible aujourd\'hui',
      serviceArea: 'Rabat, Salé, Témara',
      isAvailable: true,
    ),
    Technician(
      name: 'Fatima Zahra',
      speciality: 'Réparation',
      city: 'Marrakech',
      phone: '+212 634 567 890',
      rating: 4.7,
      reviewCount: 32,
      availability: 'Occupé jusqu\'à 16h',
      serviceArea: 'Marrakech, Essaouira',
      isAvailable: false,
    ),
    Technician(
      name: 'Hassan Bensaid',
      speciality: 'Diagnostic',
      city: 'Casablanca',
      phone: '+212 645 678 901',
      rating: 4.6,
      reviewCount: 15,
      availability: 'Disponible',
      serviceArea: 'Casablanca, Mohammedia',
      isAvailable: true,
    ),
    Technician(
      name: 'Karim El Fassi',
      speciality: 'Pompage solaire',
      city: 'Fès',
      phone: '+212 656 789 012',
      rating: 5.0,
      reviewCount: 28,
      availability: 'Disponible',
      serviceArea: 'Fès, Meknès, Taza',
      isAvailable: true,
    ),
    Technician(
      name: 'Youssef Amrani',
      speciality: 'Maintenance',
      city: 'Tanger',
      phone: '+212 667 890 123',
      rating: 4.5,
      reviewCount: 12,
      availability: 'Disponible demain',
      serviceArea: 'Tanger, Tétouan',
      isAvailable: false,
    ),
  ];
}

class Technician {
  final String name;
  final String speciality;
  final String city;
  final String phone;
  final double rating;
  final int reviewCount;
  final String availability;
  final String serviceArea;
  final bool isAvailable;

  Technician({
    required this.name,
    required this.speciality,
    required this.city,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.availability,
    required this.serviceArea,
    required this.isAvailable,
  });
}

class _TechnicianCard extends StatelessWidget {
  final Technician technician;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  const _TechnicianCard({
    required this.technician,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Availability
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technician.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        technician.speciality,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: technician.isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: technician.isAvailable
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        technician.isAvailable ? Icons.check_circle : Icons.schedule,
                        size: 16,
                        color: technician.isAvailable ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        technician.isAvailable ? 'Disponible' : 'Occupé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: technician.isAvailable ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating and Reviews
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      technician.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  '${technician.reviewCount} avis',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Availability Status
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    technician.availability,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Service Area
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zone: ${technician.serviceArea}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Appeler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
