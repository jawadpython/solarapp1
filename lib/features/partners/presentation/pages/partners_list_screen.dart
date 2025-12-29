import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';

class PartnersListScreen extends StatefulWidget {
  const PartnersListScreen({super.key});

  @override
  State<PartnersListScreen> createState() => _PartnersListScreenState();
}

class _PartnersListScreenState extends State<PartnersListScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final partners = await _adminService.getPartners();
      
      if (mounted) {
        setState(() {
          _partners = partners;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Partenaires'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _partners.isEmpty
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
                        'Aucun partenaire disponible',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPartners,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _partners.length,
                    itemBuilder: (context, index) {
                      final partner = _partners[index];
                      return _PartnerCard(partner: partner);
                    },
                  ),
                ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final Map<String, dynamic> partner;

  const _PartnerCard({required this.partner});

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
                        partner['companyName']?.toString() ?? partner['name']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (partner['speciality'] != null)
                        Text(
                          partner['speciality']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (partner['city'] != null)
              Row(
                children: [
                  Icon(Icons.location_city, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    partner['city']?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            if (partner['phone'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    partner['phone']?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

