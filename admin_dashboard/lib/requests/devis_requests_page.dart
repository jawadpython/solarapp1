import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/request_detail_dialog.dart';

class DevisRequestsPage extends StatelessWidget {
  const DevisRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demandes de Devis',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamDevisRequests(),
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
                    child: Text('Aucune demande de devis'),
                  );
                }

                return _RequestsTable(
                  documents: snapshot.data!.docs,
                  collection: 'devis_requests',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestsTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> documents;
  final String collection;

  const _RequestsTable({
    required this.documents,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Téléphone')),
            DataColumn(label: Text('Ville')),
            DataColumn(label: Text('Type Système')),
            DataColumn(label: Text('Puissance (kW)')),
            DataColumn(label: Text('Panneaux')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Actions')),
          ],
          rows: documents.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DataRow(
              cells: [
                DataCell(Text(
                  DateFormatter.formatTimestamp(data['createdAt']),
                )),
                DataCell(Text(data['fullName']?.toString() ?? 'N/A')),
                DataCell(Text(data['phone']?.toString() ?? 'N/A')),
                DataCell(Text(data['city']?.toString() ?? 'N/A')),
                DataCell(Text(data['systemType']?.toString() ?? 'N/A')),
                DataCell(Text(data['powerKW']?.toString() ?? 'N/A')),
                DataCell(Text(data['panels']?.toString() ?? 'N/A')),
                DataCell(StatusChip(status: data['status']?.toString() ?? 'pending')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => RequestDetailDialog(
                              data: data,
                              collection: collection,
                              requestId: doc.id,
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          final firestoreService = AdminFirestoreService();
                          await firestoreService.updateRequestStatus(
                            collection: collection,
                            requestId: doc.id,
                            status: value,
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'pending',
                            child: Text('En attente'),
                          ),
                          const PopupMenuItem(
                            value: 'approved',
                            child: Text('Approuvé'),
                          ),
                          const PopupMenuItem(
                            value: 'rejected',
                            child: Text('Rejeté'),
                          ),
                          const PopupMenuItem(
                            value: 'assigned',
                            child: Text('Assigné'),
                          ),
                        ],
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
  }
}

