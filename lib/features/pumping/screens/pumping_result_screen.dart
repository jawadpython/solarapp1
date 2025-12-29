import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/features/pumping/models/pumping_result.dart';

class PumpingResultScreen extends StatelessWidget {
  final PumpingResult result;

  const PumpingResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Résultat du Calcul'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Result Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assessment,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Résultats de votre dimensionnement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Basé sur votre région et les conditions saisies',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 1 — Hydraulique
            _SectionCard(
              title: 'Hydraulique',
              icon: Icons.water_drop,
              iconColor: Colors.blue,
              children: [
                _ResultItem(
                  icon: Icons.water_drop,
                  label: 'Débit (Q)',
                  value: '${result.q.toStringAsFixed(2)} m³/h',
                  color: Colors.blue,
                  description: 'Volume d\'eau pompé par heure',
                ),
                const SizedBox(height: 16),
                _ResultItem(
                  icon: Icons.height,
                  label: 'Hauteur manométrique (H)',
                  value: '${result.h.toStringAsFixed(2)} m',
                  color: Colors.orange,
                  description: 'Hauteur totale à surmonter',
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Section 2 — Système Solaire
            _SectionCard(
              title: 'Système Solaire',
              icon: Icons.solar_power,
              iconColor: Colors.amber,
              children: [
                _ResultItem(
                  icon: Icons.power,
                  label: 'Puissance pompe recommandée',
                  value: '${result.pumpKW.toStringAsFixed(2)} kW',
                  color: AppColors.primary,
                  description: 'Puissance nécessaire pour votre pompe',
                ),
                const SizedBox(height: 16),
                _ResultItem(
                  icon: Icons.solar_power,
                  label: 'Puissance PV nécessaire',
                  value: '${result.pvWp.toStringAsFixed(0)} Wp',
                  color: Colors.green,
                  description: 'Puissance photovoltaïque totale requise',
                ),
                const SizedBox(height: 16),
                _ResultItem(
                  icon: Icons.grid_view,
                  label: 'Nombre de panneaux',
                  value: '${result.panels} panneaux',
                  color: Colors.purple,
                  description: 'Panneaux solaires de 550 Wp chacun',
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Section 3 — Économie Financière
            _SectionCard(
              title: 'Économie Financière',
              icon: Icons.savings,
              iconColor: Colors.green,
              children: [
                _SavingsRow(
                  label: 'Économies mensuelles',
                  value: '${result.savingMonth.toStringAsFixed(2)} DH',
                ),
                const SizedBox(height: 12),
                _SavingsRow(
                  label: 'Économies annuelles',
                  value: '${result.savingYear.toStringAsFixed(2)} DH',
                  isHighlight: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de calcul',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Basé sur ${result.sunHoursUsed.toStringAsFixed(1)} heures solaires/jour – ${result.regionCode}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Explanation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Note importante',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ces résultats sont une estimation basée sur les données théoriques et les conditions moyennes de votre région. Le devis final nécessite une visite technique.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Demander un devis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/pumping-devis-form',
                    arguments: result,
                  );
                },
                icon: const Icon(Icons.request_quote, size: 24),
                label: const Text(
                  'Demander un devis Pompage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? description;

  const _ResultItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
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

class _SavingsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SavingsRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? Colors.green.shade300 : Colors.grey.shade300,
          width: isHighlight ? 2.5 : 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green.shade700 : Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

