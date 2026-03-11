// lib/features/documents/services/ai_document_generator.dart
// Uses Anthropic Claude API to generate medical documents

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AiDocumentGenerator {
  static final AiDocumentGenerator _instance = AiDocumentGenerator._internal();
  factory AiDocumentGenerator() => _instance;
  AiDocumentGenerator._internal();

  // ⚠️ Replace with your actual Claude API key
  // For production, store this securely (e.g. Firebase Remote Config)
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY';
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  /// Generate a referral letter
  Future<String> generateReferral({
    required String patientName,
    required String patientAge,
    required String condition,
    required String referTo,
    required String doctorName,
    required String reason,
  }) async {
    final prompt = '''
Generate a professional medical referral letter with the following details:
- Patient Name: $patientName
- Patient Age: $patientAge
- Referring Doctor: Dr. $doctorName
- Referring To: $referTo
- Condition/Diagnosis: $condition
- Reason for Referral: $reason
- Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Format it as a formal medical letter. Be concise and professional.
''';
    return await _generate(prompt);
  }

  /// Generate a leave certificate
  Future<String> generateLeaveCertificate({
    required String patientName,
    required String patientAge,
    required String diagnosis,
    required int leaveDays,
    required String doctorName,
    required String clinicName,
  }) async {
    final prompt = '''
Generate a medical leave certificate with the following details:
- Patient Name: $patientName
- Patient Age: $patientAge
- Diagnosis: $diagnosis
- Number of Leave Days Recommended: $leaveDays days
- Doctor: Dr. $doctorName
- Clinic/Hospital: $clinicName
- Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Format it as a formal medical certificate. Be professional and concise.
''';
    return await _generate(prompt);
  }

  /// Generate a prescription summary
  Future<String> generatePrescriptionSummary({
    required String patientName,
    required String patientAge,
    required String diagnosis,
    required String medications,
    required String instructions,
    required String doctorName,
  }) async {
    final prompt = '''
Generate a prescription summary document with the following details:
- Patient Name: $patientName
- Patient Age: $patientAge
- Diagnosis: $diagnosis
- Medications Prescribed: $medications
- Instructions: $instructions
- Prescribing Doctor: Dr. $doctorName
- Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Format it as a formal prescription summary. Include dosage guidance clearly.
''';
    return await _generate(prompt);
  }

  /// Generate a custom clinical note
  Future<String> generateClinicalNote({
    required String patientName,
    required String noteType,
    required String details,
    required String doctorName,
  }) async {
    final prompt = '''
Generate a professional clinical note of type "$noteType" with:
- Patient Name: $patientName
- Doctor: Dr. $doctorName
- Clinical Details: $details
- Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Format it professionally as a medical document.
''';
    return await _generate(prompt);
  }

  /// Core API call
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
        return data['content'][0]['text'] as String;
      } else {
        debugPrint('❌ API Error: ${response.statusCode} ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ AI generation error: $e');
      rethrow;
    }
  }
}
