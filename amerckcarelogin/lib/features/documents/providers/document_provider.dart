// lib/features/documents/providers/document_provider.dart

import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_local_service.dart';
import '../services/document_firestore_service.dart';

class DocumentProvider extends ChangeNotifier {
  final _local = DocumentLocalService();
  final _cloud = DocumentFirestoreService();

  List<MedicalDocument> _documents = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;

  List<MedicalDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  Future<void> loadDocuments(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await _local.getDocuments(uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load documents';
      debugPrint('❌ Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves locally always. Pass alsoToFirestore: true to also sync to cloud.
  Future<bool> saveDocument(
    MedicalDocument doc, {
    bool alsoToFirestore = false,
  }) async {
    try {
      final localOk = await _local.saveDocument(doc);
      if (!localOk) return false;

      MedicalDocument saved = doc;

      if (alsoToFirestore) {
        final cloudOk = await _cloud.saveDocument(doc);
        saved = doc.copyWith(savedToFirestore: cloudOk);
        // Update local record with the firestore flag
        await _local.saveDocument(saved);
      }

      final idx = _documents.indexWhere((d) => d.id == saved.id);
      if (idx >= 0) {
        _documents[idx] = saved;
      } else {
        _documents.insert(0, saved);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save document';
      debugPrint('❌ Save error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDocument(String uid, String docId) async {
    try {
      await _local.deleteDocument(uid, docId);
      _documents.removeWhere((d) => d.id == docId);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete document';
      debugPrint('❌ Delete error: $e');
      notifyListeners();
    }
  }

  void setGenerating(bool value) {
    _isGenerating = value;
    notifyListeners();
  }

  void clear() {
    _documents = [];
    _errorMessage = null;
    notifyListeners();
  }
}
