import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  final _adminService = AdminService();
  String? _selectedCity;
  String? _selectedSpeciality;
  List<Map<String, dynamic>> _allTechnicians = [];
  List<Map<String, dynamic>> _filteredTechnicians = [];
  bool _isLoading = true;

  List<String> _cities = ['Tous'];
  List<String> _specialities = ['Tous'];

  @override
  void initState() {
    super.initState();
    _selectedCity = 'Tous';
    _selectedSpeciality = 'Tous';
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final technicians = await _adminService.getActiveTechnicians();
      
      // Extract unique cities and specialities
      final citiesSet = <String>{'Tous'};
      final specialitiesSet = <String>{'Tous'};
      
      for (var tech in technicians) {
        final city = tech['city']?.toString();
        final speciality = tech['speciality']?.toString();
        if (city != null && city.isNotEmpty) {
          citiesSet.add(city);
        }
        if (speciality != null && speciality.isNotEmpty) {
          specialitiesSet.add(speciality);
        }
      }

      if (mounted) {
        setState(() {
          _allTechnicians = technicians;
          _cities = citiesSet.toList()..sort();
          _specialities = specialitiesSet.toList()..sort();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTechnicians = _allTechnicians.where((tech) {
        final city = tech['city']?.toString() ?? '';
        final speciality = tech['speciality']?.toString() ?? '';
        final cityMatch = _selectedCity == 'Tous' || city == _selectedCity;
        final specialityMatch = _selectedSpeciality == 'Tous' || speciality == _selectedSpeciality;
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTechnicians.isEmpty
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
                    : RefreshIndicator(
                        onRefresh: _loadTechnicians,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTechnicians.length,
                          itemBuilder: (context, index) {
                            final tech = _filteredTechnicians[index];
                            return _TechnicianCard(
                              technician: tech,
                              onCall: () => _callTechnician(tech['phone']?.toString() ?? ''),
                              onWhatsApp: () => _whatsappTechnician(tech['phone']?.toString() ?? ''),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

}

class _TechnicianCard extends StatelessWidget {
  final Map<String, dynamic> technician;
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
                        technician['name']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        technician['speciality']?.toString() ?? 'N/A',
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
                    color: (technician['active'] ?? true)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (technician['active'] ?? true)
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (technician['active'] ?? true) ? Icons.check_circle : Icons.schedule,
                        size: 16,
                        color: (technician['active'] ?? true) ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (technician['active'] ?? true) ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (technician['active'] ?? true) ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating and Reviews
            if (technician['rating'] != null)
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        (technician['rating'] as num?)?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // City
            Row(
              children: [
                Icon(Icons.location_city, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    technician['city']?.toString() ?? 'N/A',
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
