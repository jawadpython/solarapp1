import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';

class AdminTechniciansListScreen extends StatefulWidget {
  const AdminTechniciansListScreen({super.key});

  @override
  State<AdminTechniciansListScreen> createState() => _AdminTechniciansListScreenState();
}

class _AdminTechniciansListScreenState extends State<AdminTechniciansListScreen> {
  final _adminService = AdminService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _technicians = [];
  List<Map<String, dynamic>> _filteredTechnicians = [];
  bool _isLoading = true;
  String _selectedCity = 'Tous';
  List<String> _cities = ['Tous'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTechnicians);
    _loadTechnicians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTechnicians() {
    setState(() {
      _filteredTechnicians = _technicians.where((tech) {
        final name = (tech['name'] ?? '').toString().toLowerCase();
        final phone = (tech['phone'] ?? '').toString().toLowerCase();
        final city = (tech['city'] ?? '').toString();
        final searchQuery = _searchController.text.toLowerCase();
        
        final matchesSearch = searchQuery.isEmpty || 
            name.contains(searchQuery) || 
            phone.contains(searchQuery);
        final matchesCity = _selectedCity == 'Tous' || city == _selectedCity;
        
        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  Future<void> _loadTechnicians() async {
    setState(() => _isLoading = true);
    try {
      final technicians = await _adminService.getTechnicians();
      if (mounted) {
        // Extract unique cities
        final citiesSet = <String>{'Tous'};
        for (var tech in technicians) {
          final city = tech['city']?.toString();
          if (city != null && city.isNotEmpty) {
            citiesSet.add(city);
          }
        }
        
        setState(() {
          _technicians = technicians;
          _cities = citiesSet.toList()..sort();
          _filteredTechnicians = technicians;
          _isLoading = false;
        });
        _filterTechnicians();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTechnicianStatus(String technicianId, bool currentStatus) async {
    final success = await _adminService.updateTechnicianStatus(
      technicianId: technicianId,
      active: !currentStatus,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? 'Technicien activé avec succès'
                  : 'Technicien désactivé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadTechnicians();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTechnician(String technicianId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment désactiver ce technicien ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Désactiver', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _adminService.deleteTechnician(technicianId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Technicien désactivé avec succès'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadTechnicians();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la désactivation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _callTechnician(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel vers $phone (fonctionnalité à venir)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_technicians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No data available yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou téléphone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = city == _selectedCity;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCity = city;
                            _filterTechnicians();
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTechnicians,
            child: _filteredTechnicians.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun technicien trouvé',
                          style: TextStyle(
                            fontSize: 16,
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
                      final tech = _filteredTechnicians[index];
          final isActive = tech['active'] ?? true;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.build_circle,
                            color: Colors.purple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tech['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(tech['createdAt']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: isActive ? 'approved' : 'rejected'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InfoRow(icon: Icons.phone, label: 'Téléphone', value: tech['phone'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          InfoRow(icon: Icons.location_city, label: 'Ville', value: tech['city'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          InfoRow(icon: Icons.build, label: 'Spécialité', value: tech['speciality'] ?? 'N/A'),
                          if (tech['rating'] != null) ...[
                            const SizedBox(height: 12),
                            InfoRow(
                              icon: Icons.star,
                              label: 'Note',
                              value: '${tech['rating']?.toStringAsFixed(1) ?? 'N/A'} / 5.0',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callTechnician(tech['phone'] ?? ''),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Appeler'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
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
                            onPressed: () => _toggleTechnicianStatus(
                              tech['id'] ?? '',
                              isActive,
                            ),
                            icon: Icon(
                              isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                            ),
                            label: Text(isActive ? 'Désactiver' : 'Activer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive ? Colors.orange : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteTechnician(tech['id'] ?? ''),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Désactiver définitivement'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
