// lib/features/documents/services/ai_document_generator.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiDocumentGenerator {
  static final AiDocumentGenerator _instance = AiDocumentGenerator._internal();
  factory AiDocumentGenerator() => _instance;
  AiDocumentGenerator._internal();

  // ⚠️ Replace with your Claude API key from console.anthropic.com
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY';
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  // ── Public methods ────────────────────────────────────────────────────────

  Future<String> generateReferral({
    required String patientName,
    required String patientAge,
    required String condition,
    required String referTo,
    required String doctorName,
    required String clinicName,
    required String reason,
  }) => _generate('''
Write a professional medical referral letter with the following details:
- Doctor: Dr. $doctorName
- Clinic/Hospital: $clinicName
- Patient Name: $patientName
- Patient Age: $patientAge years
- Diagnosis/Condition: $condition
- Referring To: $referTo
- Reason for Referral: $reason
- Date: ${_today()}

Format it as a formal medical referral letter. Include a proper salutation, 
body explaining the patient's condition and reason for referral, and a 
professional closing. Be concise and clinical.
''');

  Future<String> generateLeaveCertificate({
    required String patientName,
    required String patientAge,
    required String diagnosis,
    required int leaveDays,
    required String doctorName,
    required String clinicName,
  }) => _generate('''
Write a medical leave certificate with the following details:
- Doctor: Dr. $doctorName
- Clinic/Hospital: $clinicName
- Patient Name: $patientName
- Patient Age: $patientAge years
- Diagnosis: $diagnosis
- Leave Recommended: $leaveDays day(s)
- Date: ${_today()}

Format it as a formal medical certificate. Include certification statement,
patient details, diagnosis, recommended leave duration, and doctor's
declaration. Be professional and concise.
''');

  Future<String> generatePrescription({
    required String patientName,
    required String patientAge,
    required String diagnosis,
    required String medications,
    required String instructions,
    required String doctorName,
    required String clinicName,
  }) => _generate('''
Write a prescription summary document with the following details:
- Doctor: Dr. $doctorName
- Clinic/Hospital: $clinicName
- Patient Name: $patientName
- Patient Age: $patientAge years
- Diagnosis: $diagnosis
- Medications Prescribed: $medications
- Instructions: ${instructions.isEmpty ? 'As directed' : instructions}
- Date: ${_today()}

Format it as a formal prescription summary. List each medication clearly
with dosage and frequency if provided. Include standard prescription
disclaimers and doctor's note. Be clear and clinical.
''');

  Future<String> generateCustomNote({
    required String patientName,
    required String noteType,
    required String details,
    required String doctorName,
    required String clinicName,
  }) => _generate('''
Write a clinical document of type: "$noteType"
- Doctor: Dr. $doctorName
- Clinic/Hospital: $clinicName
- Patient Name: ${patientName.isEmpty ? 'Not specified' : patientName}
- Clinical Details: $details
- Date: ${_today()}

Format it professionally as a formal medical document appropriate for
the document type "$noteType". Include all relevant sections a doctor
would expect in this type of document. Be thorough yet concise.
''');

  // ── Core API call ─────────────────────────────────────────────────────────

  Future<String> _generate(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        return text.trim();
      } else {
        debugPrint('❌ API Error ${response.statusCode}: ${response.body}');
        throw Exception(
          'Document generation failed (status ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('❌ AI generation error: $e');
      rethrow;
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  String _today() {
    final n = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[n.month - 1]} ${n.day}, ${n.year}';
  }
}
