// lib/features/documents/models/document_model.dart

enum DocumentType { aiWriter, referral, leaveCertificate, custom }

class MedicalDocument {
  final String id;
  final String uid;
  final DocumentType type;
  final String title;
  final String content;
  final String patientName;
  final String patientId;
  final DateTime createdAt;

  const MedicalDocument({
    required this.id,
    required this.uid,
    required this.type,
    required this.title,
    required this.content,
    required this.patientName,
    required this.patientId,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case DocumentType.aiWriter:
        return 'AI Writer';
      case DocumentType.referral:
        return 'Referral';
      case DocumentType.leaveCertificate:
        return 'Leave Certificate';
      case DocumentType.custom:
        return 'Custom';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'type': type.name,
      'title': title,
      'content': content,
      'patientName': patientName,
      'patientId': patientId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalDocument.fromMap(Map<String, dynamic> map) {
    return MedicalDocument(
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
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}