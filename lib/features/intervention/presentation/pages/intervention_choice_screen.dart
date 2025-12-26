import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/routes/app_routes.dart';

class InterventionChoiceScreen extends StatelessWidget {
  const InterventionChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Type d\'intervention'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              const Text(
                'Choisissez votre type d\'intervention',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Entreprise Partenaire Card
              _InterventionCard(
                title: 'Entreprise Partenaire',
                description: 'Projets complets, installation de systèmes solaires,\ngarantie & expertise professionnelle.',
                buttonText: 'Voir les entreprises',
                icon: Icons.business_outlined,
                iconColor: const Color(0xFF00BCD4),
                backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                borderColor: const Color(0xFF00BCD4),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.partnersList);
                },
              ),
              const SizedBox(height: 20),
              
              // Technicien Certifié Card
              _InterventionCard(
                title: 'Technicien Certifié',
                description: 'Maintenance, réparations et petites installations.',
                buttonText: 'Voir les techniciens',
                icon: Icons.build_circle_outlined,
                iconColor: const Color(0xFF673AB7),
                backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                borderColor: const Color(0xFF673AB7),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.techniciansList);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _InterventionCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

