import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/date_formatter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = AdminFirestoreService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamNotifications(),
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
                    child: Text('Aucune notification'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isSeen = data['seen'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSeen ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSeen
                              ? AppTheme.textSecondary.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.2),
                          child: Icon(
                            _getNotificationIcon(data['type']?.toString()),
                            color: isSeen ? AppTheme.textSecondary : AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          data['title']?.toString() ?? 'Notification',
                          style: TextStyle(
                            fontWeight: isSeen ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(data['message']?.toString() ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatTimestamp(data['date']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        trailing: isSeen
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () async {
                                  await firestoreService.markNotificationRead(doc.id);
                                },
                              ),
                        onTap: () async {
                          if (!isSeen) {
                            await firestoreService.markNotificationRead(doc.id);
                          }
                        },
                      ),
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

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'devis':
        return Icons.request_quote;
      case 'installation':
        return Icons.construction;
      case 'maintenance':
        return Icons.build;
      case 'pumping':
        return Icons.water_drop;
      case 'technicianApplication':
        return Icons.person_add;
      case 'partnerApplication':
        return Icons.business_center;
      default:
        return Icons.notifications;
    }
  }
}

