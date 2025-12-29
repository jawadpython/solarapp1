import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/admin/services/admin_service.dart';
import 'package:noor_energy/features/admin/widgets/admin_shared_widgets.dart';

class AdminApplicationsListScreen extends StatefulWidget {
  const AdminApplicationsListScreen({super.key});

  @override
  State<AdminApplicationsListScreen> createState() => _AdminApplicationsListScreenState();
}

class _AdminApplicationsListScreenState extends State<AdminApplicationsListScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _technicianApps = [];
  List<Map<String, dynamic>> _partnerApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final techApps = await _adminService.getTechnicianApplications();
      final partnerApps = await _adminService.getPartnerApplications();
      if (mounted) {
        setState(() {
          _technicianApps = techApps;
          _partnerApps = partnerApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveTechnician(String applicationId) async {
    final success = await _adminService.approveTechnicianApplication(applicationId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature technicien approuvée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadApplications();
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

  Future<void> _rejectTechnician(String applicationId) async {
    final success = await _adminService.rejectTechnicianApplication(applicationId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature technicien rejetée'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadApplications();
      }
    }
  }

  Future<void> _approvePartner(String applicationId) async {
    final success = await _adminService.approvePartnerApplication(applicationId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature partenaire approuvée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadApplications();
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

  Future<void> _rejectPartner(String applicationId) async {
    final success = await _adminService.rejectPartnerApplication(applicationId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature partenaire rejetée'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadApplications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalApps = _technicianApps.length + _partnerApps.length;

    if (totalApps == 0) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technician Applications Section
          if (_technicianApps.isNotEmpty) ...[
            const Text(
              'Candidatures Techniciens',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._technicianApps.map((app) => _ApplicationCard(
              name: app['name'] ?? 'N/A',
              phone: app['phone'] ?? 'N/A',
              city: app['city'] ?? 'N/A',
              email: app['email'] ?? 'N/A',
              speciality: app['speciality'] ?? 'N/A',
              date: app['createdAt'],
              onApprove: () => _approveTechnician(app['id']),
              onReject: () => _rejectTechnician(app['id']),
            )),
            const SizedBox(height: 24),
          ],
          // Partner Applications Section
          if (_partnerApps.isNotEmpty) ...[
            const Text(
              'Candidatures Partenaires',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._partnerApps.map((app) => _ApplicationCard(
              name: app['name'] ?? 'N/A',
              phone: app['phone'] ?? 'N/A',
              city: app['city'] ?? 'N/A',
              email: app['email'] ?? 'N/A',
              speciality: app['speciality'] ?? 'N/A',
              date: app['createdAt'],
              onApprove: () => _approvePartner(app['id']),
              onReject: () => _rejectPartner(app['id']),
            )),
          ],
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String name;
  final String phone;
  final String city;
  final String email;
  final String speciality;
  final dynamic date;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.name,
    required this.phone,
    required this.city,
    required this.email,
    required this.speciality,
    required this.date,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.indigo,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: 'pending'),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    InfoRow(key: const ValueKey('phone'), icon: Icons.phone, label: 'Téléphone', value: phone),
                    const SizedBox(height: 12),
                    InfoRow(key: const ValueKey('city'), icon: Icons.location_city, label: 'Ville', value: city),
                    const SizedBox(height: 12),
                    InfoRow(key: const ValueKey('email'), icon: Icons.email, label: 'Email', value: email),
                    const SizedBox(height: 12),
                    InfoRow(key: const ValueKey('speciality'), icon: Icons.build, label: 'Spécialité', value: speciality),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


