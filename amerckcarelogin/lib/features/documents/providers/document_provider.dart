// lib/features/documents/providers/document_provider.dart

import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _service = DocumentService();

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
      _documents = await _service.getDocuments(uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load documents';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDocument(MedicalDocument doc) async {
    try {
      await _service.saveDocument(doc);
      _documents.insert(0, doc);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save document';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await _service.deleteDocument(docId);
      _documents.removeWhere((d) => d.id == docId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete document';
      notifyListeners();
    }
  }

  void setGenerating(bool value) {
    _isGenerating = value;
    notifyListeners();
  }
}