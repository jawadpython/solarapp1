import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';

class TechniciansPage extends StatelessWidget {
  const TechniciansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Techniciens',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamTechnicians(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aucun technicien'),
                  );
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Téléphone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Ville')),
                        DataColumn(label: Text('Spécialité')),
                        DataColumn(label: Text('Actif')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              DateFormatter.formatTimestamp(data['createdAt']),
                            )),
                            DataCell(Text(data['name']?.toString() ?? 'N/A')),
                            DataCell(Text(data['phone']?.toString() ?? 'N/A')),
                            DataCell(Text(data['email']?.toString() ?? 'N/A')),
                            DataCell(Text(data['city']?.toString() ?? 'N/A')),
                            DataCell(Text(data['speciality']?.toString() ?? 'N/A')),
                            DataCell(
                              Icon(
                                data['active'] == true ? Icons.check_circle : Icons.cancel,
                                color: data['active'] == true ? AppTheme.successColor : AppTheme.errorColor,
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Supprimer'),
                                      content: const Text('Êtes-vous sûr de vouloir supprimer ce technicien?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await firestoreService.deleteTechnician(doc.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Technicien supprimé'),
                                          backgroundColor: AppTheme.successColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

