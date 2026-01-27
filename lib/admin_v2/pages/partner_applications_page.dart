import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/export_bar.dart';
import '../widgets/request_detail_dialog.dart';

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
                    columns: const ['Date', 'Entreprise', 'ICE', 'IF', 'RC', 'Patente', 'Adresse', 'Ville', 'Téléphone', 'Email', 'Statut'],
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
                      columns: const ['Date', 'Entreprise', 'ICE', 'RC', 'Téléphone', 'Ville', 'Email', 'Statut', 'Actions'],
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
                                        if (confirm == true) {
                                          await firestoreService.approvePartnerApplication(item['id']?.toString() ?? '');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Candidature approuvée')),
                                            );
                                          }
                                        }
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
