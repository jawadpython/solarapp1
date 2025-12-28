import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';

class TechnicianAssignmentSheet extends StatefulWidget {
  final String requestId;
  final String collection;
  final String? filterCity;

  const TechnicianAssignmentSheet({
    super.key,
    required this.requestId,
    required this.collection,
    this.filterCity,
  });

  @override
  State<TechnicianAssignmentSheet> createState() => _TechnicianAssignmentSheetState();
}

class _TechnicianAssignmentSheetState extends State<TechnicianAssignmentSheet> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoading = true;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.filterCity;
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() => _isLoading = true);
    try {
      final technicians = await _adminService.getActiveTechnicians(
        city: _selectedCity,
      );
      if (mounted) {
        setState(() {
          _technicians = technicians;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _assignTechnician(Map<String, dynamic> technician) async {
    final success = await _adminService.assignTechnician(
      collection: widget.collection,
      requestId: widget.requestId,
      technicianId: technician['id'] ?? '',
      technicianName: technician['name'] ?? 'N/A',
      technicianPhone: technician['phone'] ?? 'N/A',
    );

    if (mounted) {
      Navigator.pop(context, success);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Technicien assigné avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'assignation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Assigner un technicien',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // City Filter
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'Filtrer par ville',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Toutes les villes')),
              const DropdownMenuItem(value: 'Casablanca', child: Text('Casablanca')),
              const DropdownMenuItem(value: 'Rabat', child: Text('Rabat')),
              const DropdownMenuItem(value: 'Marrakech', child: Text('Marrakech')),
              const DropdownMenuItem(value: 'Fès', child: Text('Fès')),
              const DropdownMenuItem(value: 'Tanger', child: Text('Tanger')),
              const DropdownMenuItem(value: 'Agadir', child: Text('Agadir')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
              _loadTechnicians();
            },
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ))
          else if (_technicians.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun technicien disponible',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _technicians.length,
                itemBuilder: (context, index) {
                  final tech = _technicians[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(tech['name'] ?? 'N/A'),
                    subtitle: Text(
                      '${tech['city'] ?? 'N/A'} • ${tech['speciality'] ?? 'N/A'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _assignTechnician(tech),
                    ),
                    onTap: () => _assignTechnician(tech),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

