import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/professional_data_table.dart';
import '../widgets/skeleton_loader.dart';

class TechnicianApplicationsPage extends StatelessWidget {
  const TechnicianApplicationsPage({super.key});

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
                    'Candidatures Techniciens',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.streamTechnicianApplications(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text(
                        '$count candidature${count > 1 ? 's' : ''} au total',
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
              stream: firestoreService.streamTechnicianApplications(),
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
                          Icons.person_add_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune candidature de technicien',
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

                return _ProfessionalApplicationsTable(
                  data: data,
                  firestoreService: firestoreService,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalApplicationsTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final AdminFirestoreService firestoreService;

  const _ProfessionalApplicationsTable({
    required this.data,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalDataTable(
      data: data,
      searchHint: 'Rechercher par nom, téléphone, email, ville...',
      filterOptions: const ['pending', 'approved', 'rejected'],
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
          label: Text('Email'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Ville'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Spécialité'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Statut'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.L,
        ),
      ],
      buildRow: (item) {
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
                item['name']?.toString() ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(Text(item['phone']?.toString() ?? 'N/A')),
            DataCell(Text(item['email']?.toString() ?? 'N/A')),
            DataCell(Text(item['city']?.toString() ?? 'N/A')),
            DataCell(Text(item['speciality']?.toString() ?? 'N/A')),
            DataCell(StatusChip(status: item['status']?.toString() ?? 'pending')),
            DataCell(
              _ActionButtons(
                data: item,
                firestoreService: firestoreService,
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
  final AdminFirestoreService firestoreService;

  const _ActionButtons({
    required this.data,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = data['status']?.toString() == 'pending';
    final applicationId = data['id']?.toString() ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Details Button
        Tooltip(
          message: 'Voir les détails',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showApplicationDetails(context, data);
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
        if (isPending) ...[
          const SizedBox(width: 8),
          // Approve Button
          Tooltip(
            message: 'Approuver',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await _approveApplication(context, applicationId);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Reject Button
          Tooltip(
            message: 'Rejeter',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await _rejectApplication(context, applicationId);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _approveApplication(BuildContext context, String applicationId) async {
    try {
      await firestoreService.approveTechnicianApplication(applicationId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Candidature approuvée avec succès'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _rejectApplication(BuildContext context, String applicationId) async {
    try {
      await firestoreService.rejectTechnicianApplication(applicationId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Candidature rejetée'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showApplicationDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la candidature'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Nom', data['name']?.toString() ?? 'N/A'),
              _DetailRow('Téléphone', data['phone']?.toString() ?? 'N/A'),
              _DetailRow('Email', data['email']?.toString() ?? 'N/A'),
              _DetailRow('Ville', data['city']?.toString() ?? 'N/A'),
              _DetailRow('Spécialité', data['speciality']?.toString() ?? 'N/A'),
              if (data['experience'] != null)
                _DetailRow('Expérience', data['experience']?.toString() ?? 'N/A'),
              if (data['certifications'] != null)
                _DetailRow('Certifications', data['certifications']?.toString() ?? 'N/A'),
              if (data['notes'] != null)
                _DetailRow('Notes', data['notes']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _DetailRow('Date', DateFormatter.formatTimestamp(data['createdAt'])),
              _DetailRow('Statut', data['status']?.toString() ?? 'pending'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
