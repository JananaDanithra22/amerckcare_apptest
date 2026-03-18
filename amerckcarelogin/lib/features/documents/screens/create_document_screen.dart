// lib/features/documents/screens/create_document_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/document_provider.dart';
import '../models/document_model.dart';
import '../services/ai_document_generator.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';
import 'document_view_screen.dart';
import 'document_editor_screen.dart';

class CreateDocumentScreen extends StatefulWidget {
  final DocumentType documentType;

  const CreateDocumentScreen({Key? key, required this.documentType})
    : super(key: key);

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _clinicController = TextEditingController();
  // Referral
  final _referToController = TextEditingController();
  final _referReasonController = TextEditingController();
  final _conditionController = TextEditingController();
  // Leave cert
  final _diagnosisController = TextEditingController();
  final _leaveDaysController = TextEditingController();
  // Prescription
  final _medicationsController = TextEditingController();
  final _instructionsController = TextEditingController();
  // AI Writer / Custom
  final _noteTypeController = TextEditingController();
  final _detailsController = TextEditingController();

  String _generatedContent = '';
  bool _isGenerated = false;

  bool get _isCustom => widget.documentType == DocumentType.custom;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isCustom ? 2 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _patientNameController,
      _patientAgeController,
      _patientIdController,
      _clinicController,
      _referToController,
      _referReasonController,
      _conditionController,
      _diagnosisController,
      _leaveDaysController,
      _medicationsController,
      _instructionsController,
      _noteTypeController,
      _detailsController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _screenTitle {
    switch (widget.documentType) {
      case DocumentType.aiWriter:
        return 'AI Writer';
      case DocumentType.referral:
        return 'Referral Letter';
      case DocumentType.leaveCertificate:
        return 'Leave Certificate';
      case DocumentType.prescription:
        return 'Prescription Summary';
      case DocumentType.custom:
        return 'Custom Document';
    }
  }

  Color get _typeColor {
    switch (widget.documentType) {
      case DocumentType.aiWriter:
        return const Color(0xFF7C4DFF);
      case DocumentType.referral:
        return const Color(0xFF4CAF50);
      case DocumentType.leaveCertificate:
        return const Color(0xFFFF5252);
      case DocumentType.prescription:
        return const Color(0xFFFF9800);
      case DocumentType.custom:
        return const Color(0xFFFF6D00);
    }
  }

  Future<void> _generateDocument() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profileProv = Provider.of<ProfileProvider>(context, listen: false);
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);

    final doctorName =
        profileProv.profile?.name ??
        auth.getCurrentUserEmail()?.split('@')[0] ??
        'Doctor';
    final clinicName =
        _clinicController.text.trim().isEmpty
            ? 'AmerckCare Clinic'
            : _clinicController.text.trim();

    docProvider.setGenerating(true);

    try {
      String content = '';

      switch (widget.documentType) {
        case DocumentType.referral:
          content = await AiDocumentGenerator().generateReferral(
            patientName: _patientNameController.text.trim(),
            patientAge: _patientAgeController.text.trim(),
            condition: _conditionController.text.trim(),
            referTo: _referToController.text.trim(),
            doctorName: doctorName,
            clinicName: clinicName,
            reason: _referReasonController.text.trim(),
          );
          break;

        case DocumentType.leaveCertificate:
          content = await AiDocumentGenerator().generateLeaveCertificate(
            patientName: _patientNameController.text.trim(),
            patientAge: _patientAgeController.text.trim(),
            diagnosis: _diagnosisController.text.trim(),
            leaveDays: int.tryParse(_leaveDaysController.text) ?? 1,
            doctorName: doctorName,
            clinicName: clinicName,
          );
          break;

        case DocumentType.prescription:
          content = await AiDocumentGenerator().generatePrescription(
            patientName: _patientNameController.text.trim(),
            patientAge: _patientAgeController.text.trim(),
            diagnosis: _diagnosisController.text.trim(),
            medications: _medicationsController.text.trim(),
            instructions: _instructionsController.text.trim(),
            doctorName: doctorName,
            clinicName: clinicName,
          );
          break;

        case DocumentType.aiWriter:
        case DocumentType.custom:
          content = await AiDocumentGenerator().generateCustomNote(
            patientName: _patientNameController.text.trim(),
            noteType: _noteTypeController.text.trim(),
            details: _detailsController.text.trim(),
            doctorName: doctorName,
            clinicName: clinicName,
          );
          break;
      }

      setState(() {
        _generatedContent = content;
        _isGenerated = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate: ${e.toString()}'),
            backgroundColor: UIConstants.errorRed,
          ),
        );
      }
    } finally {
      docProvider.setGenerating(false);
    }
  }

  void _proceedToView(String content) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.getCurrentUserId() ?? '';

    final doc = MedicalDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      type: widget.documentType,
      title:
          '$_screenTitle — ${_patientNameController.text.trim().isEmpty ? 'Patient' : _patientNameController.text.trim()}',
      content: content,
      patientName: _patientNameController.text.trim(),
      patientId: _patientIdController.text.trim(),
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewScreen(doc: doc, isNew: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: _typeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom:
            _isCustom
                ? TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
                    Tab(icon: Icon(Icons.edit), text: 'Write Manually'),
                  ],
                )
                : null,
      ),
      body:
          _isCustom
              ? TabBarView(
                controller: _tabController,
                children: [_buildAiForm(docProvider), _buildManualEditor()],
              )
              : _buildAiForm(docProvider),
    );
  }

  // ── AI Form ───────────────────────────────────────────────────────────────
  Widget _buildAiForm(DocumentProvider docProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient info
            _card(
              children: [
                _sectionLabel('Patient Information'),
                _field(
                  'Full Name *',
                  _patientNameController,
                  Icons.person,
                  required: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Age *',
                        _patientAgeController,
                        Icons.cake,
                        required: true,
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        'Patient ID',
                        _patientIdController,
                        Icons.badge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  'Clinic / Hospital',
                  _clinicController,
                  Icons.local_hospital,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Type-specific fields
            _card(
              children: [
                _sectionLabel('Document Details'),
                ..._buildSpecificFields(),
              ],
            ),

            const SizedBox(height: 20),

            // Generate button
            if (!_isGenerated)
              SizedBox(
                width: double.infinity,
                height: UIConstants.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed:
                      docProvider.isGenerating ? null : _generateDocument,
                  icon:
                      docProvider.isGenerating
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.auto_awesome),
                  label: Text(
                    docProvider.isGenerating
                        ? 'Generating...'
                        : 'Generate with AI',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _typeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    ),
                  ),
                ),
              ),

            // Preview + actions
            if (_isGenerated) ...[
              _sectionLabel('Generated Document'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  border: Border.all(
                    color: _typeColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: UIConstants.shadowLight,
                ),
                child: Text(
                  _generatedContent,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          docProvider.isGenerating
                              ? null
                              : () {
                                setState(() => _isGenerated = false);
                                _generateDocument();
                              },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _typeColor,
                        side: BorderSide(color: _typeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _proceedToView(_generatedContent),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _typeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Manual editor ─────────────────────────────────────────────────────────
  Widget _buildManualEditor() {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        children: [
          _card(
            children: [
              _sectionLabel('Patient Information (optional)'),
              _field('Patient Name', _patientNameController, Icons.person),
              const SizedBox(height: 12),
              _field('Patient ID', _patientIdController, Icons.badge),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: UIConstants.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DocumentEditorScreen(),
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  _proceedToView(result);
                }
              },
              icon: const Icon(Icons.edit_note),
              label: const Text(
                'Open Text Editor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificFields() {
    const gap = SizedBox(height: 12);
    switch (widget.documentType) {
      case DocumentType.referral:
        return [
          _field(
            'Diagnosis / Condition *',
            _conditionController,
            Icons.medical_information,
            required: true,
          ),
          gap,
          _field(
            'Refer To (Specialist / Hospital) *',
            _referToController,
            Icons.local_hospital,
            required: true,
          ),
          gap,
          _field(
            'Reason for Referral *',
            _referReasonController,
            Icons.description,
            required: true,
            lines: 3,
          ),
        ];
      case DocumentType.leaveCertificate:
        return [
          _field(
            'Diagnosis *',
            _diagnosisController,
            Icons.medical_information,
            required: true,
          ),
          gap,
          _field(
            'Number of Leave Days *',
            _leaveDaysController,
            Icons.calendar_today,
            required: true,
            keyboard: TextInputType.number,
          ),
        ];
      case DocumentType.prescription:
        return [
          _field(
            'Diagnosis *',
            _diagnosisController,
            Icons.medical_information,
            required: true,
          ),
          gap,
          _field(
            'Medications *',
            _medicationsController,
            Icons.medication,
            required: true,
            lines: 3,
          ),
          gap,
          _field(
            'Instructions',
            _instructionsController,
            Icons.notes,
            lines: 2,
          ),
        ];
      case DocumentType.aiWriter:
      case DocumentType.custom:
        return [
          _field(
            'Document Type *',
            _noteTypeController,
            Icons.description,
            required: true,
            hint: 'e.g. Progress Note, Discharge Summary, Referral Letter',
          ),
          gap,
          _field(
            'Clinical Details *',
            _detailsController,
            Icons.notes,
            required: true,
            lines: 5,
          ),
        ];
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(UIConstants.radiusM),
      boxShadow: UIConstants.shadowLight,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: AppTextStyles.sectionHeader),
  );

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool required = false,
    int lines = 1,
    TextInputType? keyboard,
    String? hint,
  }) => TextFormField(
    controller: ctrl,
    maxLines: lines,
    keyboardType: keyboard,
    validator: required ? (v) => v!.trim().isEmpty ? 'Required' : null : null,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: lines == 1 ? Icon(icon, color: _typeColor, size: 20) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        borderSide: BorderSide(color: _typeColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: lines > 1 ? 12 : 0,
      ),
    ),
  );
}
