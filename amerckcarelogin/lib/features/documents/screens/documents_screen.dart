// lib/features/documents/screens/documents_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/document_provider.dart';
import '../models/document_model.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';
import 'create_document_screen.dart';
import 'document_view_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final DocumentType? initialType;

  const DocumentsScreen({Key? key, this.initialType}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid =
          Provider.of<AuthProvider>(context, listen: false).getCurrentUserId();
      if (uid != null) {
        Provider.of<DocumentProvider>(
          context,
          listen: false,
        ).loadDocuments(uid);
      }
      if (widget.initialType != null) {
        _openCreateScreen(widget.initialType!);
      }
    });
  }

  void _openCreateScreen(DocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDocumentScreen(documentType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('Quick Documents'),
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTypeGrid(),
          Expanded(child: _buildSavedDocuments(docProvider)),
        ],
      ),
    );
  }

  Widget _buildTypeGrid() {
    final types = [
      {
        'type': DocumentType.aiWriter,
        'icon': Icons.psychology,
        'color': const Color(0xFF7C4DFF),
        'label': 'AI Writer',
        'sub': 'Generate letters',
      },
      {
        'type': DocumentType.referral,
        'icon': Icons.send,
        'color': const Color(0xFF4CAF50),
        'label': 'Referral',
        'sub': 'To specialist',
      },
      {
        'type': DocumentType.leaveCertificate,
        'icon': Icons.event_note,
        'color': const Color(0xFFFF5252),
        'label': 'Leave Cert',
        'sub': 'Medical leave',
      },
      {
        'type': DocumentType.prescription,
        'icon': Icons.medication,
        'color': const Color(0xFFFF9800),
        'label': 'Prescription',
        'sub': 'Rx summary',
      },
      {
        'type': DocumentType.custom,
        'icon': Icons.edit_document,
        'color': const Color(0xFFFF6D00),
        'label': 'Custom',
        'sub': 'From scratch',
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create New Document', style: AppTextStyles.headingSmall),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children:
                types.map((t) {
                  final color = t['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _openCreateScreen(t['type'] as DocumentType),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(t['icon'] as IconData, color: color, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              t['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              t['sub'] as String,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedDocuments(DocumentProvider docProvider) {
    if (docProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (docProvider.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              'No documents yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: UIConstants.textLight,
              ),
            ),
            Text(
              'Create your first document above',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Saved Documents (${docProvider.documents.length})',
            style: AppTextStyles.headingSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
            ),
            itemCount: docProvider.documents.length,
            itemBuilder: (context, index) {
              final doc = docProvider.documents[index];
              return _DocumentCard(
                doc: doc,
                onDelete: () {
                  final uid =
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).getCurrentUserId() ??
                      '';
                  docProvider.deleteDocument(uid, doc.id);
                },
                onShare: () => Share.share(doc.content, subject: doc.title),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewScreen(doc: doc),
                      ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Document Card ─────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final MedicalDocument doc;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.doc,
    required this.onDelete,
    required this.onShare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = doc.typeColor;
    final formatted = DateFormat('MMM d, yyyy • h:mm a').format(doc.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(UIConstants.spacingS),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    ),
                    child: Icon(doc.typeIcon, color: color, size: 18),
                  ),
                  const SizedBox(width: UIConstants.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: AppTextStyles.listTileTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(formatted, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (doc.savedToFirestore)
                    Tooltip(
                      message: 'Synced to cloud',
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.cloud_done,
                          size: 16,
                          color: Colors.green.shade400,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    ),
                    child: Text(
                      doc.typeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Patient info
            if (doc.patientName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 13,
                      color: UIConstants.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doc.patientId.isNotEmpty
                          ? '${doc.patientName} · ${doc.patientId}'
                          : doc.patientName,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),

            // Content preview
            Padding(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              child: Text(
                doc.content,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Actions
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red.shade400,
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Document?'),
            content: const Text('This document will be permanently deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
