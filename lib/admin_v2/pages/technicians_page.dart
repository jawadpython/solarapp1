import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/export_bar.dart';

/// Technicians Management Page with delete functionality
class TechniciansPage extends StatelessWidget {
  const TechniciansPage({super.key});

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
                        'Techniciens',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: firestoreService.streamTechnicians(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          final activeCount = snapshot.data?.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['active'] == true;
                          }).length ?? 0;
                          return Text(
                            '$count technicien${count > 1 ? 's' : ''} ($activeCount actif${activeCount > 1 ? 's' : ''})',
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
                stream: firestoreService.streamTechnicians(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final allData = snapshot.data!.docs.map((doc) {
                    final docData = doc.data() as Map<String, dynamic>;
                    return <String, dynamic>{...docData, 'id': doc.id};
                  }).toList();
                  return ExportBar(
                    data: allData,
                    columns: const ['Date', 'Nom', 'Téléphone', 'Ville', 'Email', 'Spécialité', 'Statut'],
                    title: 'Techniciens',
                    fileName: 'technicians',
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamTechnicians(),
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
                              child: Text(item['speciality']?.toString() ?? 'N/A'),
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
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Supprimer le technicien'),
                                          content: Text('Voulez-vous supprimer ${item['name']} ?'),
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
                                        await firestoreService.deleteTechnician(item['id']?.toString() ?? '');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Technicien supprimé')),
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
