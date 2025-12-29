import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/core/services/language_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = LanguageService.instance.currentLocale;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Langue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _LanguageOption(
                      label: 'Français',
                      locale: const Locale('fr'),
                      isSelected: currentLocale.languageCode == 'fr',
                      flag: '🇫🇷',
                      onTap: () async {
                        await LanguageService.instance.setLanguage(const Locale('fr'));
                        if (mounted) {
                          setState(() {});
                          // Restart app to apply language change
                          Navigator.of(context).pushReplacementNamed('/home-screen');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LanguageOption(
                      label: 'Arabe',
                      locale: const Locale('ar'),
                      isSelected: currentLocale.languageCode == 'ar',
                      flag: '🇸🇦',
                      onTap: () async {
                        await LanguageService.instance.setLanguage(const Locale('ar'));
                        if (mounted) {
                          setState(() {});
                          // Restart app to apply language change
                          Navigator.of(context).pushReplacementNamed('/home-screen');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LanguageOption(
                      label: 'Anglais',
                      locale: const Locale('en'),
                      isSelected: currentLocale.languageCode == 'en',
                      flag: '🇬🇧',
                      onTap: () async {
                        await LanguageService.instance.setLanguage(const Locale('en'));
                        if (mounted) {
                          setState(() {});
                          // Restart app to apply language change
                          Navigator.of(context).pushReplacementNamed('/home-screen');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Other Settings (placeholder)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Paramètres',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Autres paramètres à venir...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;
  final bool isSelected;
  final String flag;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

