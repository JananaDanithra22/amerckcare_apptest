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

      // Auto-open create screen if type passed from home
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
          // Document type selector
          _buildTypeGrid(),

          // Saved documents
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
        'sub': 'Send to specialist',
      },
      {
        'type': DocumentType.leaveCertificate,
        'icon': Icons.event_note,
        'color': const Color(0xFFFF5252),
        'label': 'Leave Cert',
        'sub': 'Medical leave',
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
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(t['icon'] as IconData, color: color, size: 26),
                            const SizedBox(height: 6),
                            Text(
                              t['label'] as String,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              t['sub'] as String,
                              style: AppTextStyles.caption,
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
              return _DocumentCard(
                doc: docProvider.documents[index],
                onDelete:
                    () => docProvider.deleteDocument(
                      docProvider.documents[index].id,
                    ),
                onShare:
                    () => Share.share(
                      docProvider.documents[index].content,
                      subject: docProvider.documents[index].title,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Document Card ──
class _DocumentCard extends StatelessWidget {
  final MedicalDocument doc;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _DocumentCard({
    required this.doc,
    required this.onDelete,
    required this.onShare,
  });

  Color get _typeColor {
    switch (doc.type) {
      case DocumentType.aiWriter:
        return const Color(0xFF7C4DFF);
      case DocumentType.referral:
        return const Color(0xFF4CAF50);
      case DocumentType.leaveCertificate:
        return const Color(0xFFFF5252);
      case DocumentType.custom:
        return const Color(0xFFFF6D00);
    }
  }

  IconData get _typeIcon {
    switch (doc.type) {
      case DocumentType.aiWriter:
        return Icons.psychology;
      case DocumentType.referral:
        return Icons.send;
      case DocumentType.leaveCertificate:
        return Icons.event_note;
      case DocumentType.custom:
        return Icons.edit_document;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMM d, yyyy • h:mm a').format(doc.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
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
                    color: _typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 18),
                ),
                const SizedBox(width: UIConstants.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title, style: AppTextStyles.listTileTitle),
                      Text(formatted, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Text(
                    doc.typeLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _typeColor,
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
                    size: 14,
                    color: UIConstants.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${doc.patientName}${doc.patientId.isNotEmpty ? ' · ${doc.patientId}' : ''}',
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action buttons
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _viewDocument(context),
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
    );
  }

  void _viewDocument(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DocumentViewScreen(doc: doc)),
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

// ── Full Document View Screen ──
class _DocumentViewScreen extends StatelessWidget {
  final MedicalDocument doc;

  const _DocumentViewScreen({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(doc.title),
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(doc.content, subject: doc.title),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingL),
        child: Text(
          doc.content,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.8),
        ),
      ),
    );
  }
}
