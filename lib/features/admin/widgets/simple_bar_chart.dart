import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

/// Simple Bar Chart Widget (without external dependencies)
class SimpleBarChart extends StatelessWidget {
  final Map<String, double> data;

  const SimpleBarChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = data.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return const Center(child: Text('No data'));
    }

    return Column(
      children: data.entries.map((entry) {
        final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    entry.value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: entry.key.toLowerCase().contains('approved') || 
                               entry.key.toLowerCase().contains('normal')
                            ? Colors.green
                            : entry.key.toLowerCase().contains('rejected')
                                ? Colors.red
                                : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

