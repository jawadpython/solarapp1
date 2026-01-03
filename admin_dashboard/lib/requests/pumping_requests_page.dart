import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/request_detail_dialog.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/advanced_filters_panel.dart';
import '../widgets/enhanced_data_table.dart';
import '../widgets/export_bar.dart';
import '../widgets/technician_assignment_modal.dart';

class PumpingRequestsPage extends StatefulWidget {
  const PumpingRequestsPage({super.key});

  @override
  State<PumpingRequestsPage> createState() => _PumpingRequestsPageState();
}

class _PumpingRequestsPageState extends State<PumpingRequestsPage> {
  final _firestoreService = AdminFirestoreService();
  
  String? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _regionFilter;
  String _searchQuery = '';
  List<String> _selectedIds = [];

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    var filtered = List<Map<String, dynamic>>.from(data);
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.values.any((value) =>
            value.toString().toLowerCase().contains(query));
      }).toList();
    }
    
    if (_statusFilter != null) {
      filtered = filtered.where((item) {
        return item['status']?.toString() == _statusFilter;
      }).toList();
    }
    
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((item) {
        final createdAt = item['createdAt'];
        if (createdAt == null) return false;
        DateTime? date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is DateTime) {
          date = createdAt;
        }
        if (date == null) return false;
        if (_startDate != null && date.isBefore(_startDate!)) return false;
        if (_endDate != null && date.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
        return true;
      }).toList();
    }
    
    if (_regionFilter != null) {
      filtered = filtered.where((item) {
        return item['city']?.toString() == _regionFilter;
      }).toList();
    }
    
    return filtered;
  }

  Future<void> _handleBulkAction(String action) async {
    if (_selectedIds.isEmpty) return;
    try {
      if (action == 'approve') {
        await _firestoreService.bulkUpdateStatus(
          collection: 'pumping_requests',
          requestIds: _selectedIds,
          status: 'approved',
        );
      } else if (action == 'reject') {
        await _firestoreService.bulkUpdateStatus(
          collection: 'pumping_requests',
          requestIds: _selectedIds,
          status: 'rejected',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedIds.length} demande(s) mise(s) à jour'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _selectedIds.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demandes de Pompage',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.streamPumpingRequests(),
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
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamPumpingRequests(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return AdvancedFiltersPanel(
                onStatusFilterChanged: (status) => setState(() => _statusFilter = status),
                onDateRangeChanged: (start, end) => setState(() {
                  _startDate = start;
                  _endDate = end;
                }),
                onRegionFilterChanged: (region) => setState(() => _regionFilter = region),
                onSearchChanged: (query) => setState(() => _searchQuery = query),
                initialStatus: _statusFilter,
                initialStartDate: _startDate,
                initialEndDate: _endDate,
                initialRegion: _regionFilter,
                initialSearch: _searchQuery,
              );
            },
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamPumpingRequests(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final allData = snapshot.data!.docs.map((doc) {
                final docData = doc.data() as Map<String, dynamic>;
                return <String, dynamic>{...docData, 'id': doc.id};
              }).toList();
              final filteredData = _applyFilters(allData);
              return ExportBar(
                data: filteredData,
                columns: const ['Date', 'Nom', 'Téléphone', 'Ville', 'Mode', 'Panneaux', 'Statut'],
                title: 'Demandes de Pompage',
                fileName: 'pumping_requests',
              );
            },
          ),
          const SizedBox(height: 20),
          if (_selectedIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedIds.length} sélectionné(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _handleBulkAction('approve'),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handleBulkAction('reject'),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Rejeter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selectedIds.clear()),
                    child: const Text('Désélectionner'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.streamPumpingRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TableSkeletonLoader(rows: 10, columns: 8);
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande de pompage',
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
                final allData = snapshot.data!.docs.map((doc) {
                  final docData = doc.data() as Map<String, dynamic>;
                  return <String, dynamic>{...docData, 'id': doc.id};
                }).toList();
                final filteredData = _applyFilters(allData);
                return EnhancedDataTable(
                  data: filteredData,
                  onBulkAction: (ids) => setState(() => _selectedIds = ids),
                  rowsPerPage: 15,
                  columns: const [
                    DataColumn2(label: Text('Date'), size: ColumnSize.S),
                    DataColumn2(label: Text('Nom'), size: ColumnSize.M),
                    DataColumn2(label: Text('Téléphone'), size: ColumnSize.M),
                    DataColumn2(label: Text('Ville'), size: ColumnSize.S),
                    DataColumn2(label: Text('Mode'), size: ColumnSize.S),
                    DataColumn2(label: Text('Panneaux'), size: ColumnSize.S),
                    DataColumn2(label: Text('Statut'), size: ColumnSize.S),
                    DataColumn2(label: Text('Actions'), size: ColumnSize.M),
                  ],
                  buildRow: (item, isSelected) {
                    return DataRow2(
                      selected: isSelected,
                      cells: [
                        DataCell(Text(
                          DateFormatter.formatTimestamp(item['createdAt']),
                          style: const TextStyle(fontSize: 13),
                        )),
                        DataCell(Text(
                          item['name']?.toString() ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        )),
                        DataCell(Text(item['phone']?.toString() ?? 'N/A')),
                        DataCell(Text(item['city']?.toString() ?? 'N/A')),
                        DataCell(Text(item['mode']?.toString() ?? 'N/A')),
                        DataCell(Text(item['panels']?.toString() ?? 'N/A')),
                        DataCell(StatusChip(status: item['status']?.toString() ?? 'pending')),
                        DataCell(_ActionButtons(
                          data: item,
                          collection: 'pumping_requests',
                          requestId: item['id']?.toString() ?? '',
                          firestoreService: _firestoreService,
                        )),
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
  }
}

class _ActionButtons extends StatelessWidget {
  final Map<String, dynamic> data;
  final String collection;
  final String requestId;
  final AdminFirestoreService firestoreService;

  const _ActionButtons({
    required this.data,
    required this.collection,
    required this.requestId,
    required this.firestoreService,
  });

  Future<void> _assignTechnician(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => TechnicianAssignmentModal(
        requestId: requestId,
        collection: collection,
        onAssign: (technician) async {
          await firestoreService.assignTechnician(
            collection: collection,
            requestId: requestId,
            technician: technician,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.visibility_rounded, size: 18, color: AppTheme.infoColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.primaryColor),
          ),
          onSelected: (value) async {
            if (value == 'assign') {
              await _assignTechnician(context);
            } else {
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'approved',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: AppTheme.successColor),
                  SizedBox(width: 12),
                  Text('Approuver'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rejected',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Text('Rejeter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 18, color: AppTheme.infoColor),
                  SizedBox(width: 12),
                  Text('Assigner technicien'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'completed',
              child: Row(
                children: [
                  Icon(Icons.done_all, size: 18, color: AppTheme.successColor),
                  SizedBox(width: 12),
                  Text('Marquer terminé'),
                ],
              ),
            ),
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
          ],
        ),
      ],
    );
  }
}
