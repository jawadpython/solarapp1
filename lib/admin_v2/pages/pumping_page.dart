import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';
import '../widgets/simple_data_table.dart';
import '../widgets/advanced_filters_panel.dart';
import '../widgets/export_bar.dart';
import '../widgets/request_detail_dialog.dart';

/// Pumping Requests Page with full features
class PumpingPage extends StatefulWidget {
  const PumpingPage({super.key});

  @override
  State<PumpingPage> createState() => _PumpingPageState();
}

class _PumpingPageState extends State<PumpingPage> {
  final firestoreService = AdminFirestoreService();
  String? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _regionFilter;
  String _searchQuery = '';

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    return data.where((item) {
      if (_statusFilter != null && item['status']?.toString() != _statusFilter) return false;
      if (_startDate != null || _endDate != null) {
        final createdAt = item['createdAt'];
        if (createdAt != null) {
          DateTime? itemDate;
          if (createdAt is Timestamp) itemDate = createdAt.toDate();
          else if (createdAt is DateTime) itemDate = createdAt;
          if (itemDate != null) {
            if (_startDate != null && itemDate.isBefore(_startDate!)) return false;
            if (_endDate != null && itemDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
          }
        }
      }
      if (_regionFilter != null) {
        final city = item['city']?.toString().toLowerCase() ?? '';
        if (city != _regionFilter!.toLowerCase()) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (item['name']?.toString() ?? '').toLowerCase();
        final phone = (item['phone']?.toString() ?? '').toLowerCase();
        final city = (item['city']?.toString() ?? '').toLowerCase();
        if (!name.contains(query) && !phone.contains(query) && !city.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _assignTechnician(BuildContext context, String requestId) async {
    try {
      final technicians = await firestoreService.getActiveTechnicians();
      if (technicians.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun technicien actif disponible')),
          );
        }
        return;
      }
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Assigner un technicien'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                return ListTile(
                  title: Text(tech['name']?.toString() ?? ''),
                  subtitle: Text('${tech['city'] ?? ''} - ${tech['phone'] ?? ''}'),
                  onTap: () => Navigator.pop(context, tech),
                );
              },
            ),
          ),
        ),
      );
      if (selected != null) {
        await firestoreService.assignTechnician(
          collection: 'pumping_requests',
          requestId: requestId,
          technician: selected,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Technicien assigné avec succès')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Demandes de Pompage',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: firestoreService.streamPumpingRequests(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          final filteredCount = snapshot.hasData
                              ? _applyFilters(snapshot.data!.docs.map((doc) {
                                  final docData = doc.data() as Map<String, dynamic>;
                                  return {...docData, 'id': doc.id};
                                }).toList()).length
                              : 0;
                          return Text(
                            filteredCount == count
                                ? '$count demande${count > 1 ? 's' : ''} au total'
                                : '$filteredCount sur $count demande${count > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream: firestoreService.streamPumpingRequests(),
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
                stream: firestoreService.streamPumpingRequests(),
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.streamPumpingRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    final allData = snapshot.data?.docs.map((doc) {
                      final docData = doc.data() as Map<String, dynamic>;
                      return {...docData, 'id': doc.id};
                    }).toList() ?? [];
                    final filteredData = _applyFilters(allData);
                    return SimpleDataTable(
                      data: filteredData,
                      columns: const ['Date', 'Nom', 'Téléphone', 'Ville', 'Mode', 'Panneaux', 'Statut', 'Actions'],
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
                              child: Text(item['mode']?.toString() ?? 'N/A'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item['panels']?.toString() ?? 'N/A'),
                            ),
                            Expanded(
                              flex: 2,
                              child: StatusChip(status: item['status']?.toString() ?? 'pending'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 18),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => RequestDetailDialog(
                                          data: item,
                                          collection: 'pumping_requests',
                                          requestId: item['id']?.toString() ?? '',
                                        ),
                                      );
                                    },
                                    color: AppTheme.infoColor,
                                    tooltip: 'Voir détails',
                                  ),
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
                                        await _assignTechnician(context, item['id']?.toString() ?? '');
                                      } else {
                                        await firestoreService.updateRequestStatus(
                                          collection: 'pumping_requests',
                                          requestId: item['id']?.toString() ?? '',
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
                                        value: 'assign',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_add, size: 18),
                                            SizedBox(width: 8),
                                            Text('Assigner technicien'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(value: 'pending', child: Text('En attente')),
                                      const PopupMenuItem(value: 'approved', child: Text('Approuvé')),
                                      const PopupMenuItem(value: 'rejected', child: Text('Rejeté')),
                                      const PopupMenuItem(value: 'assigned', child: Text('Assigné')),
                                    ],
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
