import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/city_service.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// TechniciansSearchScreen - Lists and filters certified technicians
class TechniciansSearchScreen extends StatefulWidget {
  const TechniciansSearchScreen({super.key});

  @override
  State<TechniciansSearchScreen> createState() => _TechniciansSearchScreenState();
}

class _TechniciansSearchScreenState extends State<TechniciansSearchScreen> {
  final _adminService = AdminService();
  String? _selectedCity = CityService.allFilterId;
  String? _selectedSpeciality;
  List<Map<String, dynamic>> _allTechnicians = [];
  List<Map<String, dynamic>> _filteredTechnicians = [];
  bool _isLoading = true;

  List<CityFilterOption> _cityOptions = [];
  List<String> _specialities = [];

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      await CityService.instance.ensureLoaded();
      final technicians = await _adminService.getActiveTechnicians();
      
      debugPrint('Loaded ${technicians.length} technicians from service');
      
      final specialitiesSet = <String>{};
      for (var tech in technicians) {
        final speciality = tech['speciality']?.toString();
        if (speciality != null && speciality.isNotEmpty) {
          specialitiesSet.add(speciality);
        }
      }

      final cityOptions =
          CityService.instance.buildFilterOptions(technicians, locale);

      if (mounted) {
        setState(() {
          _allTechnicians = technicians;
          _cityOptions = cityOptions;
          _specialities = ['Tous', ...specialitiesSet.toList()..sort()];
          _selectedCity = CityService.allFilterId;
          _selectedSpeciality = 'Tous';
          _applyFilters();
          _isLoading = false;
        });
        
        debugPrint('Filtered technicians: ${_filteredTechnicians.length}');
        
        // Show message if no technicians found
        if (technicians.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noTechniciansFound),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading technicians: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _allTechnicians = [];
          _filteredTechnicians = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoading(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTechnicians = _allTechnicians.where((tech) {
        final speciality = tech['speciality']?.toString() ?? '';
        final cityMatch = CityService.instance.matchesCityFilter(
          tech,
          _selectedCity,
        );
        final specialityMatch = _selectedSpeciality == null || 
            _selectedSpeciality == 'Tous' || 
            speciality == _selectedSpeciality;
        return cityMatch && specialityMatch;
      }).toList();
    });
  }

  Future<void> _contactTechnician(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotCall(phone)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.searchCertifiedTechnicians),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // City Filter
                Row(
                  children: [
                    const Icon(Icons.location_city, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${localizations.city}:',
                      style: const TextStyle(
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
                          items: [
                            DropdownMenuItem(
                              value: CityService.allFilterId,
                              child: Text(localizations.all),
                            ),
                            ..._cityOptions.map((option) {
                              return DropdownMenuItem(
                                value: option.id,
                                child: Text(option.label),
                              );
                            }),
                          ],
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
                    Text(
                      '${localizations.speciality}:',
                      style: const TextStyle(
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
                              child: Text(spec == 'Tous' ? localizations.all : spec),
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
                              localizations.noTechniciansFound,
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
                              onContact: () => _contactTechnician(
                                tech['phone']?.toString() ?? '',
                              ),
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
  final VoidCallback onContact;

  const _TechnicianCard({
    required this.technician,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final name = technician['name']?.toString() ?? 'N/A';
    final locale = Localizations.localeOf(context).languageCode;
    final city = CityService.instance.getDisplayLabelForRecord(technician, locale);
    final phone = technician['phone']?.toString() ?? '';
    final speciality = technician['speciality']?.toString() ?? '';
    
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (speciality.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          speciality,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (city.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_city, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.contact),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

