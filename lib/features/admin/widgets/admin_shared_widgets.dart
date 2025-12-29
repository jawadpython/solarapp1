import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'assigned':
        return Colors.blue;
      default:
        return Colors.amber; // Changed to amber for pending (yellow)
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      case 'assigned':
        return 'Assigné';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatDate(dynamic date) {
  if (date == null) return 'N/A';
  
  try {
    DateTime? dateTime;
    
    if (date is DateTime) {
      dateTime = date;
    } else if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        dateTime = parsed;
      }
    }
    
    if (dateTime == null) {
      return date.toString();
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Same day - show time
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours} h';
    }
    
    // Yesterday
    if (difference.inDays == 1) {
      return 'Hier — ${DateFormat('HH:mm').format(dateTime)}';
    }
    
    // Within a week
    if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    }
    
    // Older - show formatted date
    return DateFormat('dd MMM yyyy — HH:mm', 'fr').format(dateTime);
  } catch (e) {
    // Fallback to simple format
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is Timestamp) {
      final dt = date.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return date.toString();
  }
}

