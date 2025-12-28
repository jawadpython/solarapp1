import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';

class AdminPartnersListScreen extends StatefulWidget {
  const AdminPartnersListScreen({super.key});

  @override
  State<AdminPartnersListScreen> createState() => _AdminPartnersListScreenState();
}

class _AdminPartnersListScreenState extends State<AdminPartnersListScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    setState(() => _isLoading = true);
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePartnerStatus(String partnerId, bool currentStatus) async {
    final success = await _adminService.updatePartnerStatus(
      partnerId: partnerId,
      active: !currentStatus,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? 'Partenaire activé avec succès'
                  : 'Partenaire désactivé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadPartners();
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

  void _callPartner(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel vers $phone (fonctionnalité à venir)')),
    );
  }

  void _whatsappPartner(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WhatsApp vers $phone (fonctionnalité à venir)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_partners.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _loadPartners,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partners.length,
        itemBuilder: (context, index) {
          final partner = _partners[index];
          final isActive = partner['active'] ?? true;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partner['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(partner['createdAt']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoRow(icon: Icons.phone, label: 'Téléphone', value: partner['phone'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  InfoRow(icon: Icons.location_city, label: 'Ville', value: partner['city'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  InfoRow(icon: Icons.email, label: 'Email', value: partner['email'] ?? 'N/A'),
                  if (partner['speciality'] != null) ...[
                    const SizedBox(height: 8),
                    InfoRow(icon: Icons.build, label: 'Spécialité', value: partner['speciality'] ?? 'N/A'),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callPartner(partner['phone'] ?? ''),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _whatsappPartner(partner['phone'] ?? ''),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _togglePartnerStatus(
                        partner['id'] ?? '',
                        isActive,
                      ),
                      icon: Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        size: 18,
                      ),
                      label: Text(isActive ? 'Désactiver' : 'Activer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
