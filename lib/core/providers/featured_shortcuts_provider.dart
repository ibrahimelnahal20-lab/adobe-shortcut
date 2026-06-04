import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shortcut_model.dart';
import '../services/firestore_service.dart';

final featuredShortcutsProvider = FutureProvider<List<ShortcutModel>>((ref) async {
  final service = FirestoreService();
  return service.getFeaturedShortcuts(limit: 10);
});
