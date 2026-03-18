// lib/features/documents/models/document_model.dart

import 'package:flutter/material.dart';

enum DocumentType { aiWriter, referral, leaveCertificate, prescription, custom }

class MedicalDocument {
  final String id;
  final String uid;
  final DocumentType type;
  final String title;
  final String content;
  final String patientName;
  final String patientId;
  final DateTime createdAt;
  final bool savedToFirestore;

  const MedicalDocument({
    required this.id,
    required this.uid,
    required this.type,
    required this.title,
    required this.content,
    required this.patientName,
    required this.patientId,
    required this.createdAt,
    this.savedToFirestore = false,
  });

  String get typeLabel {
    switch (type) {
      case DocumentType.aiWriter:
        return 'AI Writer';
      case DocumentType.referral:
        return 'Referral';
      case DocumentType.leaveCertificate:
        return 'Leave Certificate';
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.custom:
        return 'Custom';
    }
  }

  Color get typeColor {
    switch (type) {
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

  IconData get typeIcon {
    switch (type) {
      case DocumentType.aiWriter:
        return Icons.psychology;
      case DocumentType.referral:
        return Icons.send;
      case DocumentType.leaveCertificate:
        return Icons.event_note;
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.custom:
        return Icons.edit_document;
    }
  }

  MedicalDocument copyWith({bool? savedToFirestore, String? content}) {
    return MedicalDocument(
      id: id,
      uid: uid,
      type: type,
      title: title,
      content: content ?? this.content,
      patientName: patientName,
      patientId: patientId,
      createdAt: createdAt,
      savedToFirestore: savedToFirestore ?? this.savedToFirestore,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'uid': uid,
    'type': type.name,
    'title': title,
    'content': content,
    'patientName': patientName,
    'patientId': patientId,
    'createdAt': createdAt.toIso8601String(),
    'savedToFirestore': savedToFirestore,
  };

  factory MedicalDocument.fromMap(Map<String, dynamic> map) => MedicalDocument(
    id: map['id'] ?? '',
    uid: map['uid'] ?? '',
    type: DocumentType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => DocumentType.custom,
    ),
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    patientName: map['patientName'] ?? '',
    patientId: map['patientId'] ?? '',
    createdAt:
        map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
    savedToFirestore: map['savedToFirestore'] ?? false,
  );
}
