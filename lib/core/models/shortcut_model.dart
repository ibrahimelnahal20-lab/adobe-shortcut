import 'package:cloud_firestore/cloud_firestore.dart';

class ShortcutModel {
  final String id;
  final String shortcutId;
  final String app;
  final String category;
  final String function;
  final String windows;
  final String mac;

  ShortcutModel({
    required this.id,
    required this.shortcutId,
    required this.app,
    required this.category,
    required this.function,
    required this.windows,
    required this.mac,
  });

  factory ShortcutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ShortcutModel(
      id: doc.id,
      shortcutId: data['shortcutId'] as String? ?? '',
      app: data['app'] as String? ?? '',
      category: data['category'] as String? ?? '',
      function: data['function'] as String? ?? '',
      windows: data['windows'] as String? ?? '',
      mac: data['mac'] as String? ?? '',
    );
  }

  factory ShortcutModel.fromJson(Map<String, dynamic> json) {
    return ShortcutModel(
      id: json['shortcut_id'] as String? ?? '',
      shortcutId: json['shortcut_id'] as String? ?? '',
      app: json['app'] as String? ?? '',
      category: json['category'] as String? ?? '',
      function: json['function'] as String? ?? '',
      windows: json['windows'] as String? ?? '',
      mac: json['mac'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shortcutId': shortcutId,
      'app': app,
      'category': category,
      'function': function,
      'windows': windows,
      'mac': mac,
    };
  }
}
