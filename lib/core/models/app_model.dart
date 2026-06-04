import 'package:cloud_firestore/cloud_firestore.dart';

class AppModel {
  final String id;
  final String slug;
  final String name;
  final String icon;
  final bool featured;
  final int order;

  AppModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.featured,
    required this.order,
  });

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppModel(
      id: doc.id,
      slug: data['slug'] as String? ?? '',
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      featured: data['featured'] as bool? ?? false,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'name': name,
      'icon': icon,
      'featured': featured,
      'order': order,
    };
  }
}
