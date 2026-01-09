import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// CompaniesSearchScreen - Lists and filters certified companies/partners
class CompaniesSearchScreen extends StatefulWidget {
  const CompaniesSearchScreen({super.key});

  @override
  State<CompaniesSearchScreen> createState() => _CompaniesSearchScreenState();
}

class _CompaniesSearchScreenState extends State<CompaniesSearchScreen> {
  final _adminService = AdminService();
  String? _selectedCity;
  String? _selectedServiceType;
  List<Map<String, dynamic>> _allCompanies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];
  bool _isLoading = true;

  List<String> _cities = [];
  List<String> _serviceTypes = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await _adminService.getPartners();
      
      // Extract unique cities and service types
      final citiesSet = <String>{};
      final serviceTypesSet = <String>{};
      
      for (var company in companies) {
        final city = company['city']?.toString();
        final speciality = company['speciality']?.toString();
        
        if (city != null && city.isNotEmpty) {
          citiesSet.add(city);
        }
        if (speciality != null && speciality.isNotEmpty) {
          serviceTypesSet.add(speciality);
        }
      }

      if (mounted) {
        setState(() {
          _allCompanies = companies;
          _cities = ['Tous', ...citiesSet.toList()..sort()];
          _serviceTypes = ['Tous', ...serviceTypesSet.toList()..sort()];
          _selectedCity = 'Tous';
          _selectedServiceType = 'Tous';
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
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCompanies = _allCompanies.where((company) {
        final city = company['city']?.toString() ?? '';
        final speciality = company['speciality']?.toString() ?? '';
        
        final matchesCity = _selectedCity == null || 
            _selectedCity == 'Tous' || 
            city == _selectedCity;
        final matchesServiceType = _selectedServiceType == null || 
            _selectedServiceType == 'Tous' || 
            speciality == _selectedServiceType;
        
        return matchesCity && matchesServiceType;
      }).toList();
    });
  }

  Future<void> _contactCompany(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'appeler: $phone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(localizations.searchCertifiedCompanies),
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
                          items: _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city == 'Tous' ? localizations.all : city),
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
                // Service Type Filter
                Row(
                  children: [
                    const Icon(Icons.category, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${localizations.serviceType}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedServiceType,
                          isExpanded: true,
                          items: _serviceTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type == 'Tous' ? localizations.all : type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceType = value;
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
          // Companies List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCompanies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_center,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.noCompaniesFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCompanies,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCompanies.length,
                          itemBuilder: (context, index) {
                            final company = _filteredCompanies[index];
                            return _CompanyCard(
                              company: company,
                              onContact: () => _contactCompany(
                                company['phone']?.toString() ?? '',
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

class _CompanyCard extends StatelessWidget {
  final Map<String, dynamic> company;
  final VoidCallback onContact;

  const _CompanyCard({
    required this.company,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final companyName = company['companyName']?.toString() ?? 
                       company['name']?.toString() ?? 'N/A';
    final city = company['city']?.toString() ?? '';
    final phone = company['phone']?.toString() ?? '';
    final speciality = company['speciality']?.toString() ?? '';
    
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
                    Icons.business,
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
                        companyName,
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
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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

