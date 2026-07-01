import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/city_service.dart';
import 'package:noor_energy/core/widgets/empty_state_widget.dart';
import 'package:noor_energy/core/widgets/skeleton_loading.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

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
      final loc = AppLocalizations.of(context)!;
      final allLabel = loc.all;
      final locale = Localizations.localeOf(context).languageCode;
      await CityService.instance.ensureLoaded();
      final technicians = await _adminService.getActiveTechnicians();
      if (_selectedCity == null) _selectedCity = CityService.allFilterId;
      if (_selectedSpeciality == null) _selectedSpeciality = allLabel;

      final cityOptions =
          CityService.instance.buildFilterOptions(technicians, locale);
      final specialitiesSet = <String>{allLabel};

      for (var tech in technicians) {
        final speciality = tech['speciality']?.toString();
        if (speciality != null && speciality.isNotEmpty) {
          specialitiesSet.add(speciality);
        }
      }

      if (mounted) {
        setState(() {
          _allTechnicians = technicians;
          _cityOptions = cityOptions;
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
            content: Text('${AppLocalizations.of(context)!.errorLoading}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    final allLabel = AppLocalizations.of(context)!.all;
    setState(() {
      _filteredTechnicians = _allTechnicians.where((tech) {
        final speciality = tech['speciality']?.toString() ?? '';
        final cityMatch = CityService.instance.matchesCityFilter(
          tech,
          _selectedCity,
        );
        final specialityMatch = _selectedSpeciality == allLabel || speciality == _selectedSpeciality;
        return cityMatch && specialityMatch;
      }).toList();
    });
  }

  void _callTechnician(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.callToComingSoon(phone))),
    );
  }

  void _whatsappTechnician(String phone) {
    // TODO: Implement WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.whatsAppToComingSoon(phone))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.certifiedTechniciansTitle),
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
                      AppLocalizations.of(context)!.cityFilterLabel,
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
                              child: Text(AppLocalizations.of(context)!.all),
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
                      AppLocalizations.of(context)!.specialtyFilterLabel,
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
                ? const SkeletonListLoading(itemCount: 6)
                : _filteredTechnicians.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.engineering,
                        title: AppLocalizations.of(context)!.noTechnicianFound,
                        message: AppLocalizations.of(context)!.modifyFiltersOrRetry,
                        ctaLabel: AppLocalizations.of(context)!.refresh,
                        onCtaTap: _loadTechnicians,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
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
                        technician['name']?.toString() ?? AppLocalizations.of(context)!.notAvailable,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        technician['speciality']?.toString() ?? AppLocalizations.of(context)!.notAvailable,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
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
                      Flexible(
                        child: Text(
                          (technician['active'] ?? true) ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (technician['active'] ?? true) ? Colors.green : Colors.orange,
                          ),
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
                        (technician['rating'] as num?)?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.notAvailable,
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
                Icon(Icons.location_city, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    () {
                      final cityLabel = CityService.instance.getDisplayLabelForRecord(
                        technician,
                        Localizations.localeOf(context).languageCode,
                      );
                      return cityLabel.isEmpty
                          ? AppLocalizations.of(context)!.notAvailable
                          : cityLabel;
                    }(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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
