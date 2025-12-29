import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/notification_service.dart';
import 'package:intl/intl.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _notificationService.getAdminNotificationsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final unseenCount = snapshot.data!.docs
                  .where((doc) => (doc.data() as Map<String, dynamic>)['seen'] != true)
                  .length;
              
              if (unseenCount == 0) {
                return const SizedBox.shrink();
              }
              
              return TextButton.icon(
                onPressed: () async {
                  await _notificationService.markAllAdminAsSeen();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Toutes les notifications marquées comme lues'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.done_all, size: 20),
                label: Text('Tout marquer lu'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getAdminNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final isSeen = data['seen'] == true;
              
              return _NotificationCard(
                notificationId: doc.id,
                title: data['title'] ?? 'Notification',
                message: data['message'] ?? '',
                date: data['date'] ?? data['createdAt'],
                isSeen: isSeen,
                type: data['type'] ?? '',
                onTap: () async {
                  if (!isSeen) {
                    await _notificationService.markAsSeen(doc.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String notificationId;
  final String title;
  final String message;
  final dynamic date;
  final bool isSeen;
  final String type;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.date,
    required this.isSeen,
    required this.type,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'devisRequest':
        return Icons.request_quote;
      case 'installationRequest':
        return Icons.solar_power;
      case 'maintenanceRequest':
        return Icons.build;
      case 'pumpingRequest':
        return Icons.water;
      case 'technicianApplication':
        return Icons.person_add;
      case 'partnerApplication':
        return Icons.business;
      case 'statusUpdate':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'devisRequest':
        return Colors.blue;
      case 'installationRequest':
        return Colors.orange;
      case 'maintenanceRequest':
        return Colors.purple;
      case 'pumpingRequest':
        return Colors.cyan;
      case 'technicianApplication':
        return Colors.green;
      case 'partnerApplication':
        return Colors.teal;
      case 'statusUpdate':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date inconnue';
    
    try {
      Timestamp? timestamp;
      if (date is Timestamp) {
        timestamp = date;
      } else if (date is String) {
        // Try parsing ISO string
        final parsed = DateTime.tryParse(date);
        if (parsed != null) {
          timestamp = Timestamp.fromDate(parsed);
        }
      }
      
      if (timestamp != null) {
        final dateTime = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(dateTime);
        
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            if (difference.inMinutes == 0) {
              return 'À l\'instant';
            }
            return 'Il y a ${difference.inMinutes} min';
          }
          return 'Il y a ${difference.inHours} h';
        } else if (difference.inDays == 1) {
          return 'Hier';
        } else if (difference.inDays < 7) {
          return 'Il y a ${difference.inDays} jours';
        } else {
          return DateFormat('dd/MM/yyyy').format(dateTime);
        }
      }
    } catch (e) {
      // Fallback
    }
    
    return 'Date inconnue';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForType(type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSeen ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isSeen ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getIconForType(type),
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSeen ? FontWeight.w600 : FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        if (!isSeen)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


