// lib/features/voice_notes/models/voice_note_model.dart

class VoiceNote {
  final String id;
  final String uid; // doctor's user ID
  final String content; // the transcribed text
  final String title; // auto-generated title
  final DateTime createdAt;

  const VoiceNote({
    required this.id,
    required this.uid,
    required this.content,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'content': content,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VoiceNote.fromMap(Map<String, dynamic> map) {
    return VoiceNote(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      content: map['content'] ?? '',
      title: map['title'] ?? 'Untitled Note',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
    );
  }
}
