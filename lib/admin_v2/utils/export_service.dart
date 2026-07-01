import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Conditional imports for export packages
import 'package:excel/excel.dart' as excel;
import 'package:csv/csv.dart' as csv;
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

class ExportService {
  // Export to Excel
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required String fileName,
  }) async {
    try {
      final excelFile = excel.Excel.createExcel();
      excelFile.delete('Sheet1');
      final sheet = excelFile['Sheet1'];

      // Add header row
      for (int i = 0; i < columns.length; i++) {
        sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = excel.TextCellValue(columns[i]);
      }

      // Add data rows
      for (int row = 0; row < data.length; row++) {
        final item = data[row];
        int col = 0;
        for (final column in columns) {
          final value = _getFieldValue(item, column);
          sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1)).value = excel.TextCellValue(value);
          col++;
        }
      }

      final excelBytes = excelFile.save();
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

      final csvString = const csv.ListToCsvConverter().convert(rows);
      if (kIsWeb) {
        // Trigger download in web browser
        final blob = html.Blob([csvString], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.csv')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        debugPrint('CSV file ready: $fileName.csv (${csvString.length} bytes)');
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
    final pdfDoc = pw.Document();

    pdfDoc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
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
                  color: pdf.PdfColors.blue,
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
            border: pw.TableBorder.all(color: pdf.PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pdf.PdfColors.grey200),
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
      onLayout: (format) async => pdfDoc.save(),
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
      'Économies/Mois': 'savingsMonth',
      'Économies/An': 'savingsYear',
      'Région': 'regionCode',
      'GPS': 'gps',
      'Note': 'note',
      'Mode': 'mode',
      'Urgence': 'urgency',
      'Description': 'description',
      'Type de lieu': 'locationType',
      'Type Projet': 'projectType',
      'Consommation': 'consumption',
      'Unité': 'isKwh',
      'Puissance Estimée': 'estimatedPower',
      'Email': 'email',
      'Spécialité': 'speciality',
      'Type de service': 'speciality',
      'ICE': 'ICE',
      'IF': 'IF',
      'RC': 'RC',
      'Patente': 'Patente',
      'Adresse': 'adresse',
      'Entreprise': 'nomEntreprise',
      'Documents Entreprise': 'documentsEntreprise',
    };

    final field = fieldMap[column] ?? column.toLowerCase();
    final value = item[field] ?? item[field.replaceAll(' ', '_').toLowerCase()];
    
    if (value == null) return 'N/A';
    if (value is DateTime) return DateFormat('dd/MM/yyyy').format(value);
    if (value is Timestamp) return DateFormat('dd/MM/yyyy').format(value.toDate());
    if (value is bool) {
      if (field == 'isKwh') return value ? 'kWh' : 'kW';
      return value.toString();
    }
    
    return value.toString();
  }
}
