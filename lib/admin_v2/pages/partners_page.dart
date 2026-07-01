import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:noor_energy/features/admin/widgets/partner_documents_dialog.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/export_bar.dart';
import '../widgets/request_detail_dialog.dart';

/// Partners Management Page with delete functionality
class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});

  Future<void> _editPartnerServiceType(
    BuildContext context,
    AdminFirestoreService firestoreService,
    Map<String, dynamic> item,
  ) async {
    final partnerId = item['id']?.toString() ?? '';
    if (partnerId.isEmpty) return;

    final current = PartnerServiceTypes.serviceTypeFromMap(item);
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
    if (!context.mounted || picked == null) return;

    await firestoreService.updatePartnerServiceType(
      partnerId: partnerId,
      serviceType: picked,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type de service mis à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partenaires',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: firestoreService.streamPartners(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          final activeCount = snapshot.data?.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['active'] == true;
                          }).length ?? 0;
                          return Text(
                            '$count partenaire${count > 1 ? 's' : ''} ($activeCount actif${activeCount > 1 ? 's' : ''})',
                            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Export Bar
              StreamBuilder<QuerySnapshot>(
                stream: firestoreService.streamPartners(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final allData = snapshot.data!.docs.map((doc) {
                    final docData = doc.data() as Map<String, dynamic>;
                    return <String, dynamic>{...docData, 'id': doc.id};
                  }).toList();
                  return ExportBar(
                    data: allData,
                    columns: const [
                      'Date',
                      'Entreprise',
                      'ICE',
                      'IF',
                      'RC',
                      'Patente',
                      'Adresse',
                      'Ville',
                      'Téléphone',
                      'Email',
                      'Type de service',
                      'Statut',
                    ],
                    title: 'Partenaires',
                    fileName: 'partners',
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamPartners(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    final data = snapshot.data?.docs.map((doc) {
                      final docData = doc.data() as Map<String, dynamic>;
                      return {...docData, 'id': doc.id};
                    }).toList() ?? [];
                    return SimpleDataTable(
                      data: data,
                      columns: const ['Date', 'Entreprise', 'ICE', 'RC', 'Téléphone', 'Ville', 'Email', 'Type de service', 'Statut', 'Actions'],
                      buildRow: (context, item, index) {
                        final isActive = item['active'] == true;
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormatter.formatTimestamp(item['createdAt']),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['nomEntreprise']?.toString() ?? item['companyName']?.toString() ?? item['name']?.toString() ?? 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['ICE']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['RC']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['telephone']?.toString() ?? item['phone']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['ville']?.toString() ?? item['city']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['email']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                () {
                                  final st = PartnerServiceTypes.serviceTypeFromMap(item);
                                  return st.isEmpty ? '—' : st;
                                }(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.successColor.withOpacity(0.1)
                                      : AppTheme.textSecondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isActive ? AppTheme.successColor : AppTheme.textSecondary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  isActive ? 'Actif' : 'Inactif',
                                  style: TextStyle(
                                    color: isActive ? AppTheme.successColor : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.attach_file, size: 18),
                                    onPressed: () => showPartnerDocumentsDialog(context, item),
                                    color: AppTheme.primaryColor,
                                    tooltip: 'Documents entreprise',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 18),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => RequestDetailDialog(
                                          data: item,
                                          collection: 'partners',
                                          requestId: item['id']?.toString() ?? '',
                                        ),
                                      );
                                    },
                                    color: AppTheme.infoColor,
                                    tooltip: 'Voir détails',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.category, size: 18),
                                    onPressed: () => _editPartnerServiceType(
                                      context,
                                      firestoreService,
                                      item,
                                    ),
                                    color: AppTheme.primaryColor,
                                    tooltip: 'Modifier type de service',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Supprimer le partenaire'),
                                          content: Text('Voulez-vous supprimer ${item['nomEntreprise'] ?? item['companyName'] ?? item['name']} ?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Annuler'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                                              child: const Text('Supprimer'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await firestoreService.deletePartner(item['id']?.toString() ?? '');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Partenaire supprimé')),
                                          );
                                        }
                                      }
                                    },
                                    color: AppTheme.errorColor,
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
