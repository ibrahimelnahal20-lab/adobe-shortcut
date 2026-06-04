import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../services/firestore_service.dart';

final featuredAppsProvider = FutureProvider<List<AppModel>>((ref) async {
  final service = FirestoreService();
  return service.getFeaturedApps();
});

final allAppsProvider = FutureProvider<List<AppModel>>((ref) async {
  final service = FirestoreService();
  return service.getApps();
});
