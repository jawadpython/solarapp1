import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parses `documentsEntrepriseUrls` plus http(s) lines in `documentsEntreprise` text.
List<String> partnerDocumentsEntrepriseUrls(Map<String, dynamic> data) {
  final out = <String>[];
  final seen = <String>{};

  void addUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return;
    if (seen.add(s)) out.add(s);
  }

  final urls = data['documentsEntrepriseUrls'];
  if (urls is List) {
    for (final e in urls) {
      addUrl(e?.toString() ?? '');
    }
  }

  final note = data['documentsEntreprise']?.toString() ?? '';
  final trimmed = note.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    addUrl(trimmed);
  }
  for (final line in trimmed.split(RegExp(r'\r?\n'))) {
    final t = line.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) {
      addUrl(t);
    }
  }

  return out;
}

Future<void> showPartnerDocumentsDialog(BuildContext context, Map<String, dynamic> data) async {
  final docs = partnerDocumentsEntrepriseUrls(data);
  final textDoc = data['documentsEntreprise']?.toString() ?? '';

  final hasUrls = docs.isNotEmpty;
  final hasNonUrlNote = textDoc.trim().isNotEmpty &&
      !textDoc.trim().startsWith('http://') &&
      !textDoc.trim().startsWith('https://');

  if (!hasUrls && !hasNonUrlNote) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aucun document entreprise')),
    );
    return;
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Documents entreprise'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (docs.isNotEmpty)
                  ...docs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final url = entry.value;
                    final lower = url.toLowerCase();
                    final isPdf = lower.contains('.pdf');
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.image,
                        color: isPdf ? Colors.red : Colors.blue,
                      ),
                      title: Text('Fichier ${i + 1}'),
                      subtitle: Text(url, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: const Text('Ouvrir'),
                      ),
                    );
                  }),
                if (hasNonUrlNote) ...[
                  if (docs.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Note',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(textDoc),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      );
    },
  );
}
