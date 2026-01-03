import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';

class RequestDetailDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final String collection;
  final String requestId;

  const RequestDetailDialog({
    super.key,
    required this.data,
    required this.collection,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Détails de la demande',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _DetailRow('Statut', StatusChip(status: data['status']?.toString() ?? 'pending')),
              _DetailRow('Date', Text(DateFormatter.formatTimestamp(data['createdAt']))),
              if (data['name'] != null) _DetailRow('Nom', Text(data['name'].toString())),
              if (data['fullName'] != null) _DetailRow('Nom complet', Text(data['fullName'].toString())),
              if (data['phone'] != null) _DetailRow('Téléphone', Text(data['phone'].toString())),
              if (data['city'] != null) _DetailRow('Ville', Text(data['city'].toString())),
              if (data['email'] != null) _DetailRow('Email', Text(data['email'].toString())),
              if (data['systemType'] != null) _DetailRow('Type système', Text(data['systemType'].toString())),
              if (data['mode'] != null) _DetailRow('Mode', Text(data['mode'].toString())),
              if (data['powerKW'] != null) _DetailRow('Puissance (kW)', Text(data['powerKW'].toString())),
              if (data['panels'] != null) _DetailRow('Panneaux', Text(data['panels'].toString())),
              if (data['urgency'] != null) _DetailRow('Urgence', Text(data['urgency'].toString())),
              if (data['problemDescription'] != null) _DetailRow('Description', Text(data['problemDescription'].toString())),
              if (data['description'] != null) _DetailRow('Description', Text(data['description'].toString())),
              if (data['note'] != null) _DetailRow('Note', Text(data['note'].toString())),
              if (data['gps'] != null) _DetailRow('GPS', Text(data['gps'].toString())),
              if (data['location'] != null) _DetailRow('Localisation', Text(data['location'].toString())),
              if (data['projectType'] != null) _DetailRow('Type de projet', Text(data['projectType'].toString())),
              if (data['consumption'] != null) _DetailRow('Consommation', Text(data['consumption'].toString())),
              if (data['isKwh'] != null) _DetailRow('Unité', Text(data['isKwh'] == true ? 'kWh' : 'kW')),
              if (data['estimatedPower'] != null) _DetailRow('Puissance estimée (kW)', Text(data['estimatedPower'].toString())),
              if (data['panelPower'] != null) _DetailRow('Puissance panneau (W)', Text(data['panelPower'].toString())),
              if (data['userId'] != null) _DetailRow('User ID', Text(data['userId'].toString())),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;

  const _DetailRow(this.label, this.value);

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
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}

