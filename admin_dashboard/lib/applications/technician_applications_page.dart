import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';

class TechnicianApplicationsPage extends StatelessWidget {
  const TechnicianApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Candidatures Techniciens',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamTechnicianApplications(),
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
                    child: Text('Aucune candidature'),
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
                        DataColumn(label: Text('Statut')),
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
                            DataCell(StatusChip(status: data['status']?.toString() ?? 'pending')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (data['status'] == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.check, color: AppTheme.successColor),
                                      onPressed: () async {
                                        await firestoreService.approveTechnicianApplication(doc.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Candidature approuvée'),
                                              backgroundColor: AppTheme.successColor,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  if (data['status'] == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.close, color: AppTheme.errorColor),
                                      onPressed: () async {
                                        await firestoreService.rejectTechnicianApplication(doc.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Candidature rejetée'),
                                              backgroundColor: AppTheme.errorColor,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                ],
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

