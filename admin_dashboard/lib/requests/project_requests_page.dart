import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/request_detail_dialog.dart';
import '../widgets/professional_data_table.dart';
import '../widgets/skeleton_loader.dart';

class ProjectRequestsPage extends StatelessWidget {
  const ProjectRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Études & Projets',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.streamProjectRequests(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text(
                        '$count demande${count > 1 ? 's' : ''} au total',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Data Table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamProjectRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TableSkeletonLoader(rows: 10, columns: 7);
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande d\'étude',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.docs.map((doc) {
                  final docData = doc.data() as Map<String, dynamic>;
                  return {
                    ...docData,
                    'id': doc.id,
                  };
                }).toList();

                return _ProfessionalRequestsTable(
                  data: data,
                  collection: 'project_requests',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalRequestsTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String collection;

  const _ProfessionalRequestsTable({
    required this.data,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalDataTable(
      data: data,
      searchHint: 'Rechercher par nom, téléphone, ville...',
      filterOptions: const ['pending', 'approved', 'rejected', 'assigned'],
      onFilterChanged: (status) {
        // Filter is handled internally
      },
      rowsPerPage: 15,
      columns: const [
        DataColumn2(
          label: Text('Date'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Nom'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Téléphone'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Ville'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Type'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Statut'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.M,
        ),
      ],
      buildRow: (item) {
        // Extract client name - could be 'name' or 'fullName'
        final clientName = item['name']?.toString() ?? 
                          item['fullName']?.toString() ?? 
                          'N/A';
        
        // Extract phone - could be 'phone' or 'phoneNumber'
        final phone = item['phone']?.toString() ?? 
                     item['phoneNumber']?.toString() ?? 
                     'N/A';
        
        // Extract city
        final city = item['city']?.toString() ?? 'N/A';
        
        // Extract project type
        final projectType = item['projectType']?.toString() ?? 'N/A';
        
        return DataRow2(
          cells: [
            DataCell(
              Text(
                DateFormatter.formatTimestamp(item['createdAt']),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            DataCell(
              Text(
                clientName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(Text(phone)),
            DataCell(Text(city)),
            DataCell(Text(projectType)),
            DataCell(StatusChip(status: item['status']?.toString() ?? 'pending')),
            DataCell(
              _ActionButtons(
                data: item,
                collection: collection,
                requestId: item['id']?.toString() ?? '',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Map<String, dynamic> data;
  final String collection;
  final String requestId;

  const _ActionButtons({
    required this.data,
    required this.collection,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Tooltip(
          message: 'Voir les détails',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => RequestDetailDialog(
                    data: data,
                    collection: collection,
                    requestId: requestId,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.visibility_rounded,
                  size: 18,
                  color: AppTheme.infoColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Status Menu
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          onSelected: (value) async {
            final firestoreService = AdminFirestoreService();
            await firestoreService.updateRequestStatus(
              collection: collection,
              requestId: requestId,
              status: value,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Statut mis à jour: $value'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'pending',
              child: Row(
                children: [
                  Icon(Icons.pending_actions, size: 18, color: AppTheme.warningColor),
                  SizedBox(width: 12),
                  Text('En attente'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'approved',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: AppTheme.successColor),
                  SizedBox(width: 12),
                  Text('Approuvé'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rejected',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Text('Rejeté'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assigned',
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 18, color: AppTheme.infoColor),
                  SizedBox(width: 12),
                  Text('Assigné'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

