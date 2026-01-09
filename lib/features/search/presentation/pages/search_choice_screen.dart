import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/l10n/app_localizations.dart';
import 'package:noor_energy/routes/app_routes.dart';

/// SearchChoiceScreen - Allows user to choose between searching for companies or technicians
class SearchChoiceScreen extends StatelessWidget {
  const SearchChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(localizations.whatAreYouLookingFor),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Companies Card
            _ChoiceCard(
              icon: Icons.business,
              title: localizations.searchCertifiedCompanies,
              subtitle: localizations.companiesSubtitle,
              color: const Color(0xFF2196F3),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.companiesSearch);
              },
            ),
            const SizedBox(height: 24),
            // Technicians Card
            _ChoiceCard(
              icon: Icons.build,
              title: localizations.searchCertifiedTechnicians,
              subtitle: localizations.techniciansSubtitle,
              color: const Color(0xFFFF9800),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.techniciansSearch);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Large card widget for choice selection
class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

