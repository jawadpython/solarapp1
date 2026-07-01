import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';
import 'package:noor_energy/features/admin/widgets/partner_documents_dialog.dart';

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

  Future<void> _editPartnerServiceType(Map<String, dynamic> partner) async {
    final partnerId = partner['id']?.toString() ?? '';
    if (partnerId.isEmpty) return;

    final current = PartnerServiceTypes.serviceTypeFromMap(partner);
    String selected = current.isEmpty
        ? PartnerServiceTypes.canonicalLabels.first
        : current;

    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier type de service'),
              content: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: PartnerServiceTypes.canonicalLabels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => selected = v);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!mounted || picked == null) return;

    final success = await _adminService.updatePartnerServiceType(
      partnerId: partnerId,
      serviceType: picked,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Type de service mis à jour'
              : 'Erreur lors de la mise à jour',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) {
      _loadPartners();
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
        physics: const BouncingScrollPhysics(),
        itemCount: _partners.length,
        itemBuilder: (context, index) {
          final partner = _partners[index];
          final isActive = partner['active'] ?? true;
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
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.indigo,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(partner['createdAt']),
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
                          InfoRow(icon: Icons.phone, label: 'Téléphone', value: partner['phone'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          InfoRow(icon: Icons.location_city, label: 'Ville', value: partner['city'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          InfoRow(icon: Icons.email, label: 'Email', value: partner['email'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.category,
                            label: 'Type de service',
                            value: () {
                              final st = PartnerServiceTypes.serviceTypeFromMap(partner);
                              return st.isEmpty ? 'Non renseigné' : st;
                            }(),
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.attach_file,
                            label: 'Documents',
                            value: '${partnerDocumentsEntrepriseUrls(partner).length} fichier(s)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callPartner(partner['phone'] ?? ''),
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
                          child: OutlinedButton.icon(
                            onPressed: () => _whatsappPartner(partner['phone'] ?? ''),
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('WhatsApp'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                        onPressed: () => showPartnerDocumentsDialog(context, partner),
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text('Voir documents'),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _editPartnerServiceType(partner),
                        icon: const Icon(Icons.category, size: 18),
                        label: const Text('Modifier type de service'),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _togglePartnerStatus(
                          partner['id'] ?? '',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
