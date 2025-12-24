import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

/// Reusable ResultCard widget that displays project calculation results.
/// 
/// Shows different information based on project type:
/// - ON-GRID: panels, system power (kW), savings estimate
/// - OFF-GRID: panels, battery capacity
/// - HYBRID: PV size, battery storage
/// - PUMPING: PV size, panels
class ResultCard extends StatelessWidget {
  final String projectType;
  final double systemPower; // kW
  final double pvPower; // kW
  final int numberOfPanels;
  final double batteryCapacity; // Ah
  final double? estimatedSavings; // Optional for ON-GRID

  const ResultCard({
    super.key,
    required this.projectType,
    required this.systemPower,
    required this.pvPower,
    required this.numberOfPanels,
    this.batteryCapacity = 0,
    this.estimatedSavings,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(projectType);
    
    return Card(
      elevation: 4,
      shadowColor: typeColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: typeColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              typeColor.withOpacity(0.08),
              typeColor.withOpacity(0.03),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and type badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultat estimé',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          projectType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Content based on project type
            ..._buildContentForType(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentForType() {
    switch (projectType) {
      case 'ON-GRID':
        return _buildOnGridContent();
      case 'OFF-GRID':
        return _buildOffGridContent();
      case 'HYBRID':
        return _buildHybridContent();
      case 'PUMPING':
        return _buildPumpingContent();
      default:
        return [];
    }
  }

  List<Widget> _buildOnGridContent() {
    return [
      _ResultItem(
        icon: Icons.grid_view,
        label: 'Nombre de panneaux',
        value: '$numberOfPanels panneaux',
        color: Colors.blue,
      ),
      _ResultItem(
        icon: Icons.bolt,
        label: 'Puissance système',
        value: '${systemPower.toStringAsFixed(2)} kW',
        color: AppColors.primary,
      ),
      if (estimatedSavings != null)
        _ResultItem(
          icon: Icons.savings,
          label: 'Économie estimée',
          value: '${estimatedSavings!.toStringAsFixed(0)} DH/an',
          color: Colors.green,
        ),
    ];
  }

  List<Widget> _buildOffGridContent() {
    return [
      _ResultItem(
        icon: Icons.grid_view,
        label: 'Nombre de panneaux',
        value: '$numberOfPanels panneaux',
        color: Colors.blue,
      ),
      _ResultItem(
        icon: Icons.battery_charging_full,
        label: 'Capacité batterie',
        value: '${batteryCapacity.toStringAsFixed(2)} Ah',
        color: Colors.green,
      ),
      _ResultItem(
        icon: Icons.solar_power,
        label: 'Puissance PV',
        value: '${pvPower.toStringAsFixed(2)} kW',
        color: Colors.orange,
      ),
    ];
  }

  List<Widget> _buildHybridContent() {
    return [
      _ResultItem(
        icon: Icons.solar_power,
        label: 'Taille système PV',
        value: '${pvPower.toStringAsFixed(2)} kW',
        color: Colors.orange,
      ),
      _ResultItem(
        icon: Icons.battery_charging_full,
        label: 'Stockage batterie',
        value: '${batteryCapacity.toStringAsFixed(2)} Ah',
        color: Colors.green,
      ),
      _ResultItem(
        icon: Icons.grid_view,
        label: 'Nombre de panneaux',
        value: '$numberOfPanels panneaux',
        color: Colors.blue,
      ),
    ];
  }

  List<Widget> _buildPumpingContent() {
    return [
      _ResultItem(
        icon: Icons.solar_power,
        label: 'Taille système PV',
        value: '${pvPower.toStringAsFixed(2)} kW',
        color: Colors.orange,
      ),
      _ResultItem(
        icon: Icons.grid_view,
        label: 'Nombre de panneaux',
        value: '$numberOfPanels panneaux',
        color: Colors.blue,
      ),
      _ResultItem(
        icon: Icons.bolt,
        label: 'Puissance système',
        value: '${systemPower.toStringAsFixed(2)} kW',
        color: AppColors.primary,
      ),
    ];
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ON-GRID':
        return const Color(0xFFFF9800);
      case 'OFF-GRID':
        return const Color(0xFFF4B400);
      case 'PUMPING':
        return const Color(0xFF4CAF50);
      case 'HYBRID':
        return const Color(0xFF2196F3);
      default:
        return AppColors.primary;
    }
  }
}

/// Individual result item row with enhanced UI
class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_outline,
            color: color.withOpacity(0.6),
            size: 20,
          ),
        ],
      ),
    );
  }
}

