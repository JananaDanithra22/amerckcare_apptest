// lib/features/documents/services/document_local_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class DocumentLocalService {
  static String _key(String uid) => 'documents_$uid';

  Future<List<MedicalDocument>> getDocuments(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key(uid)) ?? [];
      final docs =
          raw.map((e) => MedicalDocument.fromMap(jsonDecode(e))).toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      debugPrint('❌ Local getDocuments error: $e');
      return [];
    }
  }

  Future<bool> saveDocument(MedicalDocument doc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key(doc.uid)) ?? [];

      // Remove existing entry with same id to avoid duplicates
      raw.removeWhere((e) {
        try {
          return jsonDecode(e)['id'] == doc.id;
        } catch (_) {
          return false;
        }
      });

      raw.add(jsonEncode(doc.toMap()));
      await prefs.setStringList(_key(doc.uid), raw);
      debugPrint('✅ Document saved locally: ${doc.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Local saveDocument error: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String uid, String docId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key(uid)) ?? [];

      raw.removeWhere((e) {
        try {
          return jsonDecode(e)['id'] == docId;
        } catch (_) {
          return false;
        }
      });

      await prefs.setStringList(_key(uid), raw);
      debugPrint('✅ Document deleted locally: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ Local deleteDocument error: $e');
      return false;
    }
  }

  Future<void> clearAll(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(uid));
      debugPrint('✅ All local documents cleared for: $uid');
    } catch (e) {
      debugPrint('❌ Local clearAll error: $e');
    }
  }
}
