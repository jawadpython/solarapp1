import 'package:flutter/material.dart';
import 'package:noor_energy/core/constants/app_colors.dart';

/// Simple Pie Chart Widget (without external dependencies)
/// Uses custom painting for lightweight chart rendering
class SimplePieChart extends StatelessWidget {
  final Map<String, double> data;

  const SimplePieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.cyan,
      Colors.purple,
      Colors.indigo,
    ];

    return Row(
      children: [
        // Chart visualization
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: const Size(150, 150),
            painter: _PieChartPainter(data: data, colors: colors, total: total),
          ),
        ),
        const SizedBox(width: 16),
        // Legend
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final percentage = (item.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.key}: $percentage%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double total;

  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * 3.14159 / 180; // Start from top

    int colorIndex = 0;
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

