import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/professional_data_table.dart';
import '../widgets/skeleton_loader.dart';

class TechniciansPage extends StatelessWidget {
  const TechniciansPage({super.key});

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
                    'Techniciens',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.streamTechnicians(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Text(
                        '$count technicien${count > 1 ? 's' : ''} au total',
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
              stream: firestoreService.streamTechnicians(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TableSkeletonLoader(rows: 10, columns: 6);
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
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun technicien enregistré',
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

                return _ProfessionalTechniciansTable(
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

class _ProfessionalTechniciansTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final AdminFirestoreService firestoreService;

  const _ProfessionalTechniciansTable({
    required this.data,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalDataTable(
      data: data,
      searchHint: 'Rechercher par nom, téléphone, email, ville...',
      filterOptions: const ['active', 'inactive'],
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
        final isActive = item['active'] == true;
        
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
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.successColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.successColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.successColor : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            DataCell(
              _ActionButtons(
                data: item,
                firestoreService: firestoreService,
                isActive: isActive,
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
  final bool isActive;

  const _ActionButtons({
    required this.data,
    required this.firestoreService,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final technicianId = data['id']?.toString() ?? '';

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
                _showTechnicianDetails(context, data);
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
        // Toggle Active/Inactive Button
        Tooltip(
          message: isActive ? 'Désactiver' : 'Activer',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await _toggleActiveStatus(context, technicianId, !isActive);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.warningColor.withOpacity(0.1)
                      : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  size: 18,
                  color: isActive ? AppTheme.warningColor : AppTheme.successColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Delete Button
        Tooltip(
          message: 'Supprimer',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await _deleteTechnician(context, technicianId, data['name']?.toString() ?? 'ce technicien');
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  size: 18,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleActiveStatus(BuildContext context, String technicianId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(technicianId)
          .update({'active': newStatus});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Technicien activé' : 'Technicien désactivé'),
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

  Future<void> _deleteTechnician(BuildContext context, String technicianId, String technicianName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 24),
            SizedBox(width: 12),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer $technicianName ?\n\nCette action est irréversible.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await firestoreService.deleteTechnician(technicianId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Technicien supprimé avec succès'),
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
              content: Text('Erreur lors de la suppression: $e'),
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
  }

  void _showTechnicianDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Détails du technicien'),
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
              const SizedBox(height: 12),
              _DetailRow('Date d\'ajout', DateFormatter.formatTimestamp(data['createdAt'])),
              _DetailRow(
                'Statut',
                data['active'] == true ? 'Actif' : 'Inactif',
                isStatus: true,
                isActive: data['active'] == true,
              ),
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
  final bool isStatus;
  final bool isActive;

  const _DetailRow(
    this.label,
    this.value, {
    this.isStatus = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.successColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.successColor.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppTheme.successColor : Colors.grey.shade700,
                      ),
                    ),
                  )
                : Text(
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
