import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_html/html.dart' as html;

class ExportService {
  // Export to Excel
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required String fileName,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Sheet1'];

      // Add header row
      for (int i = 0; i < columns.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(columns[i]);
      }

      // Add data rows
      for (int row = 0; row < data.length; row++) {
        final item = data[row];
        int col = 0;
        for (final column in columns) {
          final value = _getFieldValue(item, column);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1)).value = TextCellValue(value);
          col++;
        }
      }

      final excelBytes = excel.save();
      if (excelBytes != null && kIsWeb) {
        // Trigger download in web browser
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else if (excelBytes != null) {
        debugPrint('Excel file ready: $fileName.xlsx (${excelBytes.length} bytes)');
      }
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      rethrow;
    }
  }

  // Export to CSV
  static Future<void> exportToCSV({
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required String fileName,
  }) async {
    try {
      final rows = <List<dynamic>>[];
      
      // Add header
      rows.add(columns);
      
      // Add data rows
      for (final item in data) {
        rows.add(columns.map((col) => _getFieldValue(item, col)).toList());
      }

      final csv = const ListToCsvConverter().convert(rows);
      if (kIsWeb) {
        // Trigger download in web browser
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        debugPrint('CSV file ready: $fileName.csv (${csv.length} bytes)');
      }
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      rethrow;
    }
  }

  // Export to PDF
  static Future<void> exportToPDF({
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required String title,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Tawfir Energy',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Page ${context.pageNumber} sur ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: columns.map((col) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    col,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                )).toList(),
              ),
              // Data rows
              ...data.map((item) => pw.TableRow(
                children: columns.map((col) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    _getFieldValue(item, col),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                )).toList(),
              )),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // Print
  static Future<void> printData({
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required String title,
  }) async {
    await exportToPDF(
      data: data,
      columns: columns,
      title: title,
      fileName: 'print',
    );
  }

  static String _getFieldValue(Map<String, dynamic> item, String column) {
    // Map column names to data fields
    final fieldMap = {
      'Date': 'createdAt',
      'Nom': 'fullName',
      'Téléphone': 'phone',
      'Ville': 'city',
      'Type Système': 'systemType',
      'Puissance': 'powerKW',
      'Panneaux': 'panels',
      'Statut': 'status',
    };

    final field = fieldMap[column] ?? column.toLowerCase();
    final value = item[field];
    
    if (value == null) return 'N/A';
    if (value is DateTime) return DateFormat('dd/MM/yyyy').format(value);
    if (value is Timestamp) return DateFormat('dd/MM/yyyy').format(value.toDate());
    
    return value.toString();
  }
}

