// lib/features/documents/services/document_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/document_model.dart';

class DocumentFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'documents';

  Future<bool> saveDocument(MedicalDocument doc) async {
    try {
      await _db.collection(_collection).doc(doc.id).set(doc.toMap());
      debugPrint('✅ Document synced to Firestore: ${doc.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore saveDocument error: $e');
      return false;
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
      debugPrint('❌ Firestore getDocuments error: $e');
      return [];
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await _db.collection(_collection).doc(docId).delete();
      debugPrint('✅ Document deleted from Firestore: $docId');
    } catch (e) {
      debugPrint('❌ Firestore deleteDocument error: $e');
    }
  }
}
