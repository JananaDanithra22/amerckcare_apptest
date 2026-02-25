// lib/features/voice_notes/providers/voice_notes_provider.dart

import 'package:flutter/material.dart';
import '../models/voice_note_model.dart';
import '../services/voice_notes_service.dart';

class VoiceNotesProvider extends ChangeNotifier {
  final VoiceNotesService _service = VoiceNotesService();

  List<VoiceNote> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VoiceNote> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotes(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _service.getNotes(uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load notes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveNote(VoiceNote note) async {
    try {
      await _service.saveNote(note);
      _notes.insert(0, note); // Add to top of list immediately
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save note';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _service.deleteNote(noteId);
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete note';
      notifyListeners();
    }
  }
}
