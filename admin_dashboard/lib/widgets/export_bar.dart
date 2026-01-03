import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/export_service.dart';

class ExportBar extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final String title;
  final String fileName;

  const ExportBar({
    super.key,
    required this.data,
    required this.columns,
    required this.title,
    required this.fileName,
  });

  Future<void> _exportExcel() async {
    await ExportService.exportToExcel(
      data: data,
      columns: columns,
      fileName: fileName,
    );
  }

  Future<void> _exportCSV() async {
    await ExportService.exportToCSV(
      data: data,
      columns: columns,
      fileName: fileName,
    );
  }

  Future<void> _exportPDF() async {
    await ExportService.exportToPDF(
      data: data,
      columns: columns,
      title: title,
      fileName: fileName,
    );
  }

  Future<void> _print() async {
    await ExportService.printData(
      data: data,
      columns: columns,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.download_rounded, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          const Text(
            'Exporter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: _exportExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportCSV,
            icon: const Icon(Icons.description, size: 18),
            label: const Text('CSV'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportPDF,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _print,
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Imprimer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ],
      ),
    );
  }
}

