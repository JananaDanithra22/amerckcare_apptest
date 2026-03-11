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

class CreateDocumentScreen extends StatefulWidget {
  final DocumentType documentType;

  const CreateDocumentScreen({Key? key, required this.documentType})
    : super(key: key);

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _diagnosisController = TextEditingController();

  // Referral fields
  final _referToController = TextEditingController();
  final _referReasonController = TextEditingController();

  // Leave cert fields
  final _leaveDaysController = TextEditingController();
  final _clinicController = TextEditingController();

  // Prescription fields
  final _medicationsController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Custom / AI Writer fields
  final _noteTypeController = TextEditingController();
  final _detailsController = TextEditingController();

  String _generatedContent = '';
  bool _isGenerated = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _patientIdController.dispose();
    _diagnosisController.dispose();
    _referToController.dispose();
    _referReasonController.dispose();
    _leaveDaysController.dispose();
    _clinicController.dispose();
    _medicationsController.dispose();
    _instructionsController.dispose();
    _noteTypeController.dispose();
    _detailsController.dispose();
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
      case DocumentType.custom:
        return const Color(0xFFFF6D00);
    }
  }

  Future<void> _generateDocument() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);

    final doctorName =
        profileProvider.profile?.name ??
        (auth.getCurrentUserEmail()?.split('@')[0] ?? 'Doctor');

    docProvider.setGenerating(true);

    try {
      String content = '';

      switch (widget.documentType) {
        case DocumentType.referral:
          content = await AiDocumentGenerator().generateReferral(
            patientName: _patientNameController.text.trim(),
            patientAge: _patientAgeController.text.trim(),
            condition: _diagnosisController.text.trim(),
            referTo: _referToController.text.trim(),
            doctorName: doctorName,
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
            clinicName: _clinicController.text.trim(),
          );
          break;

        case DocumentType.aiWriter:
          content = await AiDocumentGenerator().generatePrescriptionSummary(
            patientName: _patientNameController.text.trim(),
            patientAge: _patientAgeController.text.trim(),
            diagnosis: _diagnosisController.text.trim(),
            medications: _medicationsController.text.trim(),
            instructions: _instructionsController.text.trim(),
            doctorName: doctorName,
          );
          break;

        case DocumentType.custom:
          content = await AiDocumentGenerator().generateClinicalNote(
            patientName: _patientNameController.text.trim(),
            noteType: _noteTypeController.text.trim(),
            details: _detailsController.text.trim(),
            doctorName: doctorName,
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

  Future<void> _saveDocument() async {
    if (_generatedContent.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.getCurrentUserId();
    if (uid == null) return;

    final doc = MedicalDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      type: widget.documentType,
      title: '${_screenTitle} - ${_patientNameController.text.trim()}',
      content: _generatedContent,
      patientName: _patientNameController.text.trim(),
      patientId: _patientIdController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await Provider.of<DocumentProvider>(
      context,
      listen: false,
    ).saveDocument(doc);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Document saved!' : '❌ Failed to save'),
          backgroundColor:
              success ? UIConstants.successGreen : UIConstants.errorRed,
        ),
      );
      if (success) Navigator.pop(context);
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Common patient fields
              _buildSectionHeader('Patient Information'),
              const SizedBox(height: UIConstants.spacingS),
              _buildField(
                'Patient Full Name *',
                _patientNameController,
                Icons.person,
                required: true,
              ),
              const SizedBox(height: UIConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Age *',
                      _patientAgeController,
                      Icons.cake,
                      required: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: _buildField(
                      'Patient ID',
                      _patientIdController,
                      Icons.badge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingM),

              // Type-specific fields
              _buildTypeSpecificFields(),

              const SizedBox(height: UIConstants.spacingL),

              // Generate Button
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.auto_awesome),
                    label: Text(
                      docProvider.isGenerating
                          ? 'Generating...'
                          : 'Generate Document',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                      ),
                    ),
                  ),
                ),

              // Generated content preview
              if (_isGenerated) ...[
                _buildSectionHeader('Generated Document'),
                const SizedBox(height: UIConstants.spacingS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(UIConstants.spacingM),
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
                const SizedBox(height: UIConstants.spacingM),

                Row(
                  children: [
                    // Regenerate
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
                    const SizedBox(width: UIConstants.spacingM),
                    // Save
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveDocument,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
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

              const SizedBox(height: UIConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (widget.documentType) {
      case DocumentType.referral:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Referral Details'),
            const SizedBox(height: UIConstants.spacingS),
            _buildField(
              'Diagnosis / Condition *',
              _diagnosisController,
              Icons.medical_information,
              required: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Refer To (Specialist/Hospital) *',
              _referToController,
              Icons.local_hospital,
              required: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Reason for Referral *',
              _referReasonController,
              Icons.description,
              required: true,
              maxLines: 3,
            ),
          ],
        );

      case DocumentType.leaveCertificate:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Leave Certificate Details'),
            const SizedBox(height: UIConstants.spacingS),
            _buildField(
              'Diagnosis *',
              _diagnosisController,
              Icons.medical_information,
              required: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Number of Leave Days *',
              _leaveDaysController,
              Icons.calendar_today,
              required: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Clinic / Hospital Name *',
              _clinicController,
              Icons.local_hospital,
              required: true,
            ),
          ],
        );

      case DocumentType.aiWriter:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Prescription Details'),
            const SizedBox(height: UIConstants.spacingS),
            _buildField(
              'Diagnosis *',
              _diagnosisController,
              Icons.medical_information,
              required: true,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Medications Prescribed *',
              _medicationsController,
              Icons.medication,
              required: true,
              maxLines: 3,
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Instructions / Notes',
              _instructionsController,
              Icons.description,
              maxLines: 3,
            ),
          ],
        );

      case DocumentType.custom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Document Details'),
            const SizedBox(height: UIConstants.spacingS),
            _buildField(
              'Note Type *',
              _noteTypeController,
              Icons.description,
              required: true,
              hint: 'e.g. Progress Note, Discharge Summary',
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildField(
              'Clinical Details *',
              _detailsController,
              Icons.notes,
              required: true,
              maxLines: 5,
            ),
          ],
        );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: UIConstants.spacingS),
      child: Text(title, style: AppTextStyles.sectionHeader),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator:
            required
                ? (v) => v!.trim().isEmpty ? '$label is required' : null
                : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              maxLines == 1 ? Icon(icon, color: _typeColor, size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: UIConstants.spacingM,
            vertical: maxLines > 1 ? UIConstants.spacingM : 0,
          ),
        ),
      ),
    );
  }
}
