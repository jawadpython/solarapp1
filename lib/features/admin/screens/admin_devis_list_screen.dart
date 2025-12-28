import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';

class AdminDevisListScreen extends StatefulWidget {
  const AdminDevisListScreen({super.key});

  @override
  State<AdminDevisListScreen> createState() => _AdminDevisListScreenState();
}

class _AdminDevisListScreenState extends State<AdminDevisListScreen> {
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
      final requests = await _adminService.getDevisRequests();
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
      collection: 'devis_requests',
      requestId: requestId,
      status: 'approved',
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devis approuvé avec succès'),
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
      collection: 'devis_requests',
      requestId: requestId,
      status: 'rejected',
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devis rejeté'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadRequests();
      }
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
          return _RequestCard(
            requestId: request['id'] ?? '',
            name: request['fullName'] ?? 'N/A',
            phone: request['phone'] ?? 'N/A',
            city: request['city'] ?? 'N/A',
            systemType: request['systemType'] ?? 'N/A',
            status: request['status'] ?? 'pending',
            date: request['date'] ?? request['createdAt'],
            onApprove: () => _approveRequest(request['id'] ?? ''),
            onReject: () => _rejectRequest(request['id'] ?? ''),
            onCall: () => _callClient(request['phone'] ?? ''),
            onWhatsApp: () => _whatsappClient(request['phone'] ?? ''),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String requestId;
  final String name;
  final String phone;
  final String city;
  final String systemType;
  final String status;
  final dynamic date;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  const _RequestCard({
    required this.requestId,
    required this.name,
    required this.phone,
    required this.city,
    required this.systemType,
    required this.status,
    required this.date,
    required this.onApprove,
    required this.onReject,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
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
                    name,
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
              formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            InfoRow(icon: Icons.phone, label: 'Téléphone', value: phone),
            const SizedBox(height: 8),
            InfoRow(icon: Icons.location_city, label: 'Ville', value: city),
            const SizedBox(height: 8),
            InfoRow(icon: Icons.solar_power, label: 'Système', value: systemType),
            const SizedBox(height: 12),
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
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
                      onPressed: onReject,
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
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
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
                    onPressed: onWhatsApp,
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
  }
}


