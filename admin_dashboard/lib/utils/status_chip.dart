import 'package:flutter/material.dart';
import 'app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'en attente':
        return AppTheme.warningColor;
      case 'approved':
      case 'approuvé':
        return AppTheme.successColor;
      case 'rejected':
      case 'rejeté':
        return AppTheme.errorColor;
      case 'assigned':
      case 'assigné':
        return AppTheme.infoColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      case 'assigned':
        return 'Assigné';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

