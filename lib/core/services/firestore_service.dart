import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_model.dart';
import '../models/shortcut_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<AppModel>> getApps() async {
    try {
      final snapshot = await _db.collection('apps').get();
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting apps: $e');
      return [];
    }
  }

  Future<List<AppModel>> getFeaturedApps() async {
    try {
      final snapshot = await _db
          .collection('apps')
          .where('featured', isEqualTo: true)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting featured apps: $e');
      return [];
    }
  }

  Future<List<ShortcutModel>> getFeaturedShortcuts({int limit = 6}) async {
    try {
      final snapshot = await _db
          .collection('shortcuts')
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ShortcutModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting featured shortcuts: $e');
      return [];
    }
  }

  Future<List<ShortcutModel>> getShortcutsByApp(String appSlug) async {
    try {
      final snapshot = await _db
          .collection('shortcuts')
          .where('app', isEqualTo: appSlug)
          .get();
      return snapshot.docs
          .map((doc) => ShortcutModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting shortcuts by app: $e');
      return [];
    }
  }

  Future<List<ShortcutModel>> getAllShortcuts() async {
    try {
      final snapshot = await _db.collection('shortcuts').get();
      return snapshot.docs
          .map((doc) => ShortcutModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting all shortcuts: $e');
      return [];
    }
  }
}
