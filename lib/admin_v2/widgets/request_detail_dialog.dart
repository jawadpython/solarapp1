import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/status_chip.dart';
import '../utils/date_formatter.dart';

List<dynamic> _certificateUrlsList(Map<String, dynamic> data) {
  final urls = data['certificateUrls'];
  if (urls == null) return const [];
  if (urls is List) return urls;
  return const [];
}

List<dynamic> _partnerDocumentUrlsList(Map<String, dynamic> data) {
  final urls = data['documentsEntrepriseUrls'];
  if (urls == null) return const [];
  if (urls is List) return urls;
  return const [];
}

bool _isImageUrl(String url) {
  final lower = url.toLowerCase();
  return lower.contains('.jpg') ||
      lower.contains('.jpeg') ||
      lower.contains('.png') ||
      lower.contains('.webp');
}

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

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text('Image non disponible', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  Text(
                    collection == 'partners' || collection == 'partner_applications'
                        ? 'Informations de l\'entreprise'
                        : 'Détails de la demande',
                    style: const TextStyle(
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
              if (collection != 'partners' && collection != 'partner_applications')
                _DetailRow('Statut', StatusChip(status: data['status']?.toString() ?? 'pending')),
              _DetailRow('Date', Text(DateFormatter.formatTimestamp(data['createdAt']))),
              // Company/Partner Information (shown first for partners)
              if (collection == 'partners' || collection == 'partner_applications') ...[
                if (data['nomEntreprise'] != null) _DetailRow('Nom Entreprise', Text(data['nomEntreprise'].toString())),
                if (data['companyName'] != null && data['nomEntreprise'] == null) _DetailRow('Nom Entreprise', Text(data['companyName'].toString())),
                if (data['name'] != null && data['nomEntreprise'] == null && data['companyName'] == null) _DetailRow('Nom Entreprise', Text(data['name'].toString())),
                if (data['ICE'] != null) _DetailRow('ICE', Text(data['ICE'].toString())),
                if (data['IF'] != null) _DetailRow('IF', Text(data['IF'].toString())),
                if (data['RC'] != null) _DetailRow('RC', Text(data['RC'].toString())),
                if (data['Patente'] != null) _DetailRow('Patente', Text(data['Patente'].toString())),
                if (data['adresse'] != null) _DetailRow('Adresse', Text(data['adresse'].toString())),
                if (data['ville'] != null) _DetailRow('Ville', Text(data['ville'].toString())),
                if (data['city'] != null && data['ville'] == null) _DetailRow('Ville', Text(data['city'].toString())),
                if (data['telephone'] != null) _DetailRow('Téléphone', Text(data['telephone'].toString())),
                if (data['phone'] != null && data['telephone'] == null) _DetailRow('Téléphone', Text(data['phone'].toString())),
                if (data['email'] != null) _DetailRow('Email', Text(data['email'].toString())),
                _DetailRow(
                  'Type de service',
                  Text(
                    (() {
                      final st = PartnerServiceTypes.serviceTypeFromMap(data);
                      return st.isEmpty ? 'Non renseigné' : st;
                    })(),
                  ),
                ),
                if (data['documentsEntreprise'] != null) _DetailRow('Documents Entreprise', Text(data['documentsEntreprise'].toString())),
                if (data['active'] != null) _DetailRow('Statut', Text(data['active'] == true ? 'Actif' : 'Inactif')),
                if (data['status'] != null) _DetailRow('Statut Candidature', StatusChip(status: data['status']?.toString() ?? 'pending')),
              ] else ...[
                // Request Information (for other collections)
                if (data['name'] != null) _DetailRow('Nom', Text(data['name'].toString())),
                if (data['fullName'] != null) _DetailRow('Nom complet', Text(data['fullName'].toString())),
                if (data['phone'] != null) _DetailRow('Téléphone', Text(data['phone'].toString())),
                if (data['city'] != null) _DetailRow('Ville', Text(data['city'].toString())),
                if (data['email'] != null) _DetailRow('Email', Text(data['email'].toString())),
              ],
              if (data['systemType'] != null) _DetailRow('Type système', Text(data['systemType'].toString())),
              if (data['mode'] != null) _DetailRow('Mode', Text(data['mode'].toString())),
              if (data['powerKW'] != null) _DetailRow('Puissance (kW)', Text(data['powerKW'].toString())),
              if (data['panels'] != null) _DetailRow('Panneaux', Text(data['panels'].toString())),
              if (data['urgency'] != null) _DetailRow('Urgence', Text(data['urgency'].toString())),
              if (data['problemDescription'] != null) _DetailRow('Description', Text(data['problemDescription'].toString())),
              if (data['description'] != null) _DetailRow('Description', Text(data['description'].toString())),
              if (data['note'] != null) _DetailRow('Note', Text(data['note'].toString())),
              if (data['gps'] != null) _DetailRow('Adresse', Text(data['gps'].toString())),
              if (data['location'] != null) _DetailRow('Adresse', Text(data['location'].toString())),
              if (data['projectType'] != null) _DetailRow('Type de projet', Text(data['projectType'].toString())),
              if (data['consumption'] != null) _DetailRow('Consommation', Text(data['consumption'].toString())),
              if (data['isKwh'] != null) _DetailRow('Unité', Text(data['isKwh'] == true ? 'kWh' : 'kW')),
              if (data['estimatedPower'] != null) _DetailRow('Puissance estimée (kW)', Text(data['estimatedPower'].toString())),
              if (data['panelPower'] != null) _DetailRow('Puissance panneau (W)', Text(data['panelPower'].toString())),
              if (data['savingsMonth'] != null) _DetailRow('Économies/Mois', Text(data['savingsMonth'].toString())),
              if (data['savingsYear'] != null) _DetailRow('Économies/An', Text(data['savingsYear'].toString())),
              if (data['regionCode'] != null) _DetailRow('Région', Text(data['regionCode'].toString())),
              if (data['locationType'] != null) _DetailRow('Type de lieu', Text(data['locationType'].toString())),
              // Request-specific fields (only for requests, not partners)
              if (collection != 'partners' && collection != 'partner_applications') ...[
                if (data['systemType'] != null) _DetailRow('Type système', Text(data['systemType'].toString())),
                if (data['mode'] != null) _DetailRow('Mode', Text(data['mode'].toString())),
                if (data['powerKW'] != null) _DetailRow('Puissance (kW)', Text(data['powerKW'].toString())),
                if (data['panels'] != null) _DetailRow('Panneaux', Text(data['panels'].toString())),
                if (data['urgency'] != null) _DetailRow('Urgence', Text(data['urgency'].toString())),
                if (data['problemDescription'] != null) _DetailRow('Description', Text(data['problemDescription'].toString())),
                if (data['description'] != null) _DetailRow('Description', Text(data['description'].toString())),
                if (data['note'] != null) _DetailRow('Note', Text(data['note'].toString())),
                if (data['gps'] != null) _DetailRow('Adresse', Text(data['gps'].toString())),
                if (data['location'] != null) _DetailRow('Adresse', Text(data['location'].toString())),
                if (data['projectType'] != null) _DetailRow('Type de projet', Text(data['projectType'].toString())),
                if (data['consumption'] != null) _DetailRow('Consommation', Text(data['consumption'].toString())),
                if (data['isKwh'] != null) _DetailRow('Unité', Text(data['isKwh'] == true ? 'kWh' : 'kW')),
                if (data['estimatedPower'] != null) _DetailRow('Puissance estimée (kW)', Text(data['estimatedPower'].toString())),
                if (data['panelPower'] != null) _DetailRow('Puissance panneau (W)', Text(data['panelPower'].toString())),
                if (data['savingsMonth'] != null) _DetailRow('Économies/Mois', Text(data['savingsMonth'].toString())),
                if (data['savingsYear'] != null) _DetailRow('Économies/An', Text(data['savingsYear'].toString())),
                if (data['regionCode'] != null) _DetailRow('Région', Text(data['regionCode'].toString())),
                if (data['locationType'] != null) _DetailRow('Type de lieu', Text(data['locationType'].toString())),
                if (data['assignedTechnician'] != null) 
                  _DetailRow('Technicien Assigné', Text(data['assignedTechnician']['name']?.toString() ?? 'N/A')),
              ],
              if (data['userId'] != null) _DetailRow('User ID', Text(data['userId'].toString())),
              // Technician certificates text
              if (data['certificates'] != null && data['certificates'].toString().isNotEmpty)
                _DetailRow('Certificats', Text(data['certificates'].toString())),
              // Certificate Images Section
              if (_certificateUrlsList(data).isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Images des Certificats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _certificateUrlsList(data).length,
                    itemBuilder: (context, index) {
                      final imageUrl = _certificateUrlsList(data)[index].toString();
                      return GestureDetector(
                        onTap: () => _showFullImage(context, imageUrl),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image, size: 48, color: AppTheme.textSecondary),
                                        const SizedBox(height: 8),
                                        const Text('Image non disponible', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: () => launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication),
                                          icon: const Icon(Icons.open_in_new, size: 18),
                                          label: const Text('Ouvrir l\'image'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_certificateUrlsList(data).length} image(s) - Cliquez pour agrandir',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
              if (_partnerDocumentUrlsList(data).isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Documents Entreprise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _partnerDocumentUrlsList(data).length,
                  itemBuilder: (context, index) {
                    final docUrl = _partnerDocumentUrlsList(data)[index].toString();
                    final isImage = _isImageUrl(docUrl);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isImage ? Icons.image : Icons.picture_as_pdf,
                        color: isImage ? AppTheme.infoColor : AppTheme.errorColor,
                      ),
                      title: Text('Document ${index + 1}'),
                      subtitle: Text(
                        docUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: TextButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(docUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Ouvrir'),
                      ),
                    );
                  },
                ),
              ],
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
