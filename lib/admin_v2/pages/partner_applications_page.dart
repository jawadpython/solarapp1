import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:noor_energy/features/admin/widgets/partner_documents_dialog.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/export_bar.dart';
import '../widgets/request_detail_dialog.dart';

Future<void> runApprovePartnerApplication({
  required BuildContext context,
  required AdminFirestoreService firestoreService,
  required Map<String, dynamic> item,
}) async {
  final id = item['id']?.toString() ?? '';
  if (id.isEmpty) return;

  final resolved = PartnerServiceTypes.serviceTypeFromMap(item);
  String? specialityOverride;

  if (resolved.isEmpty) {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selected = PartnerServiceTypes.canonicalLabels.first;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Approuver la candidature'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Aucun type de service n\'est indiqué sur cette candidature. Choisissez celui qui sera enregistré pour le partenaire :',
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  child: const Text('Approuver'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!context.mounted || picked == null) return;
    specialityOverride = picked;
  } else {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approuver la candidature'),
        content: const Text('Voulez-vous approuver cette candidature ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirm != true) return;
  }

  await firestoreService.approvePartnerApplication(
    id,
    specialityOverride: specialityOverride,
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Candidature approuvée')),
    );
  }
}

/// Partner Applications Page with approve/reject
class PartnerApplicationsPage extends StatelessWidget {
  const PartnerApplicationsPage({super.key});

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
                        'Candidatures Partenaires',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: firestoreService.streamPartnerApplications(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          final pendingCount = snapshot.data?.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['status']?.toString() == 'pending';
                          }).length ?? 0;
                          return Text(
                            '$count candidature${count > 1 ? 's' : ''} ($pendingCount en attente)',
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
                stream: firestoreService.streamPartnerApplications(),
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
                    title: 'Candidatures Partenaires',
                    fileName: 'partner_applications',
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamPartnerApplications(),
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
                              child: StatusChip(status: item['status']?.toString() ?? 'pending'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  if (item['status']?.toString() == 'pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check, size: 18),
                                      onPressed: () async {
                                        await runApprovePartnerApplication(
                                          context: context,
                                          firestoreService: firestoreService,
                                          item: item,
                                        );
                                      },
                                      color: AppTheme.successColor,
                                      tooltip: 'Approuver',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Rejeter la candidature'),
                                            content: const Text('Voulez-vous rejeter cette candidature ?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Annuler'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                                                child: const Text('Rejeter'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await firestoreService.rejectPartnerApplication(item['id']?.toString() ?? '');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Candidature rejetée')),
                                            );
                                          }
                                        }
                                      },
                                      color: AppTheme.errorColor,
                                      tooltip: 'Rejeter',
                                    ),
                                  ],
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
                                          collection: 'partner_applications',
                                          requestId: item['id']?.toString() ?? '',
                                        ),
                                      );
                                    },
                                    color: AppTheme.infoColor,
                                    tooltip: 'Voir détails',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Supprimer la candidature'),
                                          content: const Text(
                                            'Supprimer définitivement cette candidature ? Cette action est irréversible.',
                                          ),
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
                                        try {
                                          await firestoreService.deletePartnerApplication(
                                            item['id']?.toString() ?? '',
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Candidature supprimée')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Échec: $e'),
                                                backgroundColor: AppTheme.errorColor,
                                              ),
                                            );
                                          }
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
