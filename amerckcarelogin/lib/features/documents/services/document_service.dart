// lib/features/documents/services/document_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/document_model.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'documents';

  Future<void> saveDocument(MedicalDocument doc) async {
    try {
      await _db.collection(_collection).doc(doc.id).set(doc.toMap());
      debugPrint('✅ Document saved: ${doc.id}');
    } catch (e) {
      debugPrint('❌ Error saving document: $e');
      rethrow;
    }
  }

  Future<List<MedicalDocument>> getDocuments(String uid) async {
    try {
      final snapshot =
          await _db
              .collection(_collection)
              .where('uid', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs
          .map((doc) => MedicalDocument.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching documents: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await _db.collection(_collection).doc(docId).delete();
      debugPrint('✅ Document deleted');
    } catch (e) {
      debugPrint('❌ Error deleting document: $e');
      rethrow;
    }
  }
}
