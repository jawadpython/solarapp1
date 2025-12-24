import 'package:flutter/material.dart';
import 'package:noor_energy/routes/app_routes.dart';

class ProjectTypeScreen extends StatelessWidget {
  const ProjectTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Étude de projet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionnez le type de projet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _ProjectTypeCard(
                    title: 'ON-GRID',
                    color: const Color(0xFFFF9800),
                    onTap: () => _navigateToForm(context, 'ON-GRID'),
                  ),
                  _ProjectTypeCard(
                    title: 'OFF-GRID',
                    color: const Color(0xFFF4B400),
                    onTap: () => _navigateToForm(context, 'OFF-GRID'),
                  ),
                  _ProjectTypeCard(
                    title: 'PUMPING',
                    color: const Color(0xFF4CAF50),
                    onTap: () => _navigateToForm(context, 'PUMPING'),
                  ),
                  _ProjectTypeCard(
                    title: 'HYBRID',
                    color: const Color(0xFF2196F3),
                    onTap: () => _navigateToForm(context, 'HYBRID'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String type) {
    switch (type) {
      case 'ON-GRID':
        Navigator.pushNamed(context, AppRoutes.onGridForm);
        break;
      case 'OFF-GRID':
        Navigator.pushNamed(context, AppRoutes.offGridForm);
        break;
      case 'HYBRID':
        Navigator.pushNamed(context, AppRoutes.hybridForm);
        break;
      case 'PUMPING':
        Navigator.pushNamed(context, AppRoutes.pumpingForm);
        break;
      default:
        Navigator.pushNamed(context, AppRoutes.onGridForm);
    }
  }
}

class _ProjectTypeCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ProjectTypeCard({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.solar_power,
                size: 72,
                color: Colors.white.withOpacity(0.95),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

