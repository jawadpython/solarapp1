import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Simple Data Table Widget for Flutter Web
/// 
/// Uses ListView instead of DataTable2 to avoid rendering issues
/// CRITICAL: Properly constrained for Flutter Web
class SimpleDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final Widget Function(BuildContext, Map<String, dynamic>, int) buildRow;
  final String? emptyMessage;

  const SimpleDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.buildRow,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Aucune donnée à afficher',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  child: Text(
                    col,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: index < data.length - 1 ? 1 : 0,
                      ),
                    ),
                  ),
                  child: buildRow(context, data[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
