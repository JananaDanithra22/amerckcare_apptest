// lib/features/documents/screens/document_view_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/document_provider.dart';
import '../models/document_model.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';

class DocumentViewScreen extends StatelessWidget {
  final MedicalDocument doc;
  final bool isNew;

  const DocumentViewScreen({Key? key, required this.doc, this.isNew = false})
    : super(key: key);

  Future<void> _saveLocally(BuildContext context) async {
    final prov = Provider.of<DocumentProvider>(context, listen: false);
    final ok = await prov.saveDocument(doc);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '✅ Saved to device' : '❌ Save failed'),
          backgroundColor: ok ? UIConstants.successGreen : UIConstants.errorRed,
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }

  Future<void> _saveToFirestore(BuildContext context) async {
    final prov = Provider.of<DocumentProvider>(context, listen: false);
    final ok = await prov.saveDocument(doc, alsoToFirestore: true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? '✅ Saved locally + synced to cloud' : '❌ Save failed',
          ),
          backgroundColor: ok ? UIConstants.successGreen : UIConstants.errorRed,
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build:
              (pw.Context ctx) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    doc.title,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Patient: ${doc.patientName}'
                    '${doc.patientId.isNotEmpty ? ' · ${doc.patientId}' : ''}',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    doc.content,
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.justify,
                  ),
                ],
              ),
        ),
      );
      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ PDF export failed: $e'),
            backgroundColor: UIConstants.errorRed,
          ),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: doc.content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('📋 Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final color = doc.typeColor;

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: Text(doc.typeLabel),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: UIConstants.shadowLight,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(doc.typeIcon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.title, style: AppTextStyles.headingSmall),
                        if (doc.patientName.isNotEmpty)
                          Text(
                            doc.patientId.isNotEmpty
                                ? '${doc.patientName} · ${doc.patientId}'
                                : doc.patientName,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Document content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: UIConstants.shadowLight,
              ),
              child: Text(
                doc.content,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.8),
              ),
            ),

            const SizedBox(height: 20),

            // Share / Export
            Text('Share / Export', style: AppTextStyles.headingSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                _shareBtn(
                  Icons.share,
                  'Share Text',
                  const Color(0xFF2196F3),
                  () => Share.share(doc.content, subject: doc.title),
                ),
                const SizedBox(width: 10),
                _shareBtn(
                  Icons.picture_as_pdf,
                  'Export PDF',
                  const Color(0xFFE53935),
                  () => _exportPdf(context),
                ),
                const SizedBox(width: 10),
                _shareBtn(
                  Icons.copy,
                  'Copy',
                  const Color(0xFF607D8B),
                  () => _copyToClipboard(context),
                ),
              ],
            ),

            // Save options — only for new unsaved docs
            if (isNew) ...[
              const SizedBox(height: 20),
              Text('Save Document', style: AppTextStyles.headingSmall),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _saveLocally(context),
                  icon: const Icon(Icons.phone_android),
                  label: const Text(
                    'Save to Device Only',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _saveToFirestore(context),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text(
                    'Save + Sync to Cloud',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Discard (don\'t save)',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _shareBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
