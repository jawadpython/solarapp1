import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';
import 'package:noor_energy/features/admin/widgets/technician_assignment_sheet.dart';

class AdminInstallationListScreen extends StatefulWidget {
  const AdminInstallationListScreen({super.key});

  @override
  State<AdminInstallationListScreen> createState() => _AdminInstallationListScreenState();
}

class _AdminInstallationListScreenState extends State<AdminInstallationListScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _adminService.getInstallationRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveRequest(String requestId) async {
    final success = await _adminService.updateRequestStatus(
      collection: 'installation_requests',
      requestId: requestId,
      status: 'approved',
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande approuvée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'approbation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final success = await _adminService.updateRequestStatus(
      collection: 'installation_requests',
      requestId: requestId,
      status: 'rejected',
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande rejetée'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadRequests();
      }
    }
  }

  Future<void> _assignTechnician(String requestId, String? city) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TechnicianAssignmentSheet(
        requestId: requestId,
        collection: 'installation_requests',
        filterCity: city,
      ),
    );
    if (result == true) {
      _loadRequests();
    }
  }

  void _callClient(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel vers $phone (fonctionnalité à venir)')),
    );
  }

  void _whatsappClient(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WhatsApp vers $phone (fonctionnalité à venir)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No data available yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          final status = request['status'] ?? 'pending';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(request['createdAt']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoRow(icon: Icons.phone, label: 'Téléphone', value: request['phone'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  InfoRow(icon: Icons.location_city, label: 'Ville', value: request['city'] ?? 'N/A'),
                  if (request['systemType'] != null)
                    InfoRow(icon: Icons.solar_power, label: 'Système', value: request['systemType'] ?? 'N/A'),
                  if (request['assignedTechnicianName'] != null) ...[
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.person,
                      label: 'Technicien assigné',
                      value: request['assignedTechnicianName'] ?? 'N/A',
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (status == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveRequest(request['id'] ?? ''),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approuver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectRequest(request['id'] ?? ''),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Rejeter'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _assignTechnician(
                          request['id'] ?? '',
                          request['city'],
                        ),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Assigner un technicien'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callClient(request['phone'] ?? ''),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _whatsappClient(request['phone'] ?? ''),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
