// lib/features/voice_notes/services/voice_notes_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/voice_note_model.dart';

class VoiceNotesService {
  static final VoiceNotesService _instance = VoiceNotesService._internal();
  factory VoiceNotesService() => _instance;
  VoiceNotesService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'voice_notes';

  /// Save a new voice note
  Future<void> saveNote(VoiceNote note) async {
    try {
      await _db.collection(_collection).doc(note.id).set(note.toMap());
      debugPrint('✅ Voice note saved: ${note.id}');
    } catch (e) {
      debugPrint('❌ Error saving voice note: $e');
      rethrow;
    }
  }

  /// Get all notes for a user (newest first)
  Future<List<VoiceNote>> getNotes(String uid) async {
    try {
      final snapshot =
          await _db
              .collection(_collection)
              .where('uid', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => VoiceNote.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('❌ Error fetching notes: $e');
      rethrow;
    }
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _db.collection(_collection).doc(noteId).delete();
      debugPrint('✅ Voice note deleted: $noteId');
    } catch (e) {
      debugPrint('❌ Error deleting note: $e');
      rethrow;
    }
  }
}
