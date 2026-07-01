import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/export_bar.dart';
import '../widgets/request_detail_dialog.dart';

/// Technician Applications Page with approve/reject
class TechnicianApplicationsPage extends StatelessWidget {
  const TechnicianApplicationsPage({super.key});

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
                        'Candidatures Techniciens',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: firestoreService.streamTechnicianApplications(),
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
                stream: firestoreService.streamTechnicianApplications(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final allData = snapshot.data!.docs.map((doc) {
                    final docData = doc.data() as Map<String, dynamic>;
                    return <String, dynamic>{...docData, 'id': doc.id};
                  }).toList();
                  return ExportBar(
                    data: allData,
                    columns: const ['Date', 'Nom', 'Téléphone', 'Ville', 'Email', 'Spécialité', 'Statut'],
                    title: 'Candidatures Techniciens',
                    fileName: 'technician_applications',
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamTechnicianApplications(),
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
                      columns: const ['Date', 'Nom', 'Téléphone', 'Ville', 'Email', 'Spécialité', 'Statut', 'Actions'],
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
                                item['name']?.toString() ?? 'N/A',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item['phone']?.toString() ?? 'N/A'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item['city']?.toString() ?? 'N/A'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item['email']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 12)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(child: Text(item['speciality']?.toString() ?? 'N/A')),
                                  if (item['certificateUrls'] != null && (item['certificateUrls'] as List).isNotEmpty)
                                    Tooltip(
                                      message: '${(item['certificateUrls'] as List).length} certificat(s)',
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        margin: const EdgeInsets.only(left: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.infoColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.image, size: 14, color: AppTheme.infoColor),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${(item['certificateUrls'] as List).length}',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.infoColor, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
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
                                          await firestoreService.approveTechnicianApplication(item['id']?.toString() ?? '');
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
                                          await firestoreService.rejectTechnicianApplication(item['id']?.toString() ?? '');
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
                                          collection: 'technician_applications',
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
                                          await firestoreService.deleteTechnicianApplication(
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
