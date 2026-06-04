import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_model.dart';
import '../../../core/models/shortcut_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../shortcuts/providers/shortcuts_providers.dart';
import '../../../core/providers/platform_provider.dart';
import '../../shortcuts/services/client_search_service.dart';

// 1. Current App Fetcher
final currentAppProvider = FutureProvider.family<AppModel?, String>((ref, slug) async {
  final service = FirestoreService();
  final apps = await service.getApps();
  try {
    return apps.firstWhere((app) => app.slug == slug);
  } catch (e) {
    return null;
  }
});

// 2. Base Shortcuts for App
final appShortcutsProvider = FutureProvider.family<List<ShortcutModel>, String>((ref, slug) async {
  // Reuse the global allShortcutsProvider to avoid extra reads
  final allShortcuts = await ref.watch(allShortcutsProvider.future);
  return allShortcuts.where((s) => s.app == slug).toList();
});

// 3. App Statistics Model
class AppStats {
  final int totalShortcuts;
  final List<String> categories;
  final bool windowsSupported;
  final bool macSupported;

  AppStats({
    required this.totalShortcuts,
    required this.categories,
    required this.windowsSupported,
    required this.macSupported,
  });
}

final appStatsProvider = FutureProvider.family<AppStats, String>((ref, slug) async {
  final shortcuts = await ref.watch(appShortcutsProvider(slug).future);
  
  final categories = <String>{};
  bool win = false;
  bool mac = false;
  
  for (var s in shortcuts) {
    if (s.category.isNotEmpty) categories.add(s.category);
    if (s.windows.isNotEmpty) win = true;
    if (s.mac.isNotEmpty) mac = true;
  }
  
  return AppStats(
    totalShortcuts: shortcuts.length,
    categories: categories.toList()..sort(),
    windowsSupported: win,
    macSupported: mac,
  );
});

// 4. Local State: Search Query
class AppSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}
final appSearchQueryProvider = NotifierProvider<AppSearchQueryNotifier, String>(AppSearchQueryNotifier.new);

// 4.1 Local State: Search Mode
class AppSearchModeNotifier extends Notifier<SearchMode> {
  @override
  SearchMode build() => SearchMode.text;

  void setMode(SearchMode mode) {
    if (state != mode) {
      state = mode;
      ref.read(appSearchQueryProvider.notifier).update('');
    }
  }
}
final appSearchModeProvider = NotifierProvider<AppSearchModeNotifier, SearchMode>(AppSearchModeNotifier.new);

// 5. Local State: Selected Category
class AppCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all'; // Default to "all"
  void update(String category) => state = category;
}
final appCategoryProvider = NotifierProvider<AppCategoryNotifier, String>(AppCategoryNotifier.new);

// 6. Final Filtered Shortcuts for App
final filteredAppShortcutsProvider = FutureProvider.family<List<ShortcutModel>, String>((ref, slug) async {
  final appShortcuts = await ref.watch(appShortcutsProvider(slug).future);
  final query = ref.watch(appSearchQueryProvider);
  final category = ref.watch(appCategoryProvider);
  final platform = ref.watch(platformProvider);
  
  // Use ClientSearchService for text/platform filtering
  // Pass appSlug: null because appShortcuts is already strictly filtered by appSlug!
  final searchService = ClientSearchService(allShortcuts: appShortcuts);
  var results = await searchService.search(
    query: query,
    platform: platform,
    appSlug: null,
  );
  
  // Additional Category Filtering
  if (category != 'all') {
    results = results.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
  }
  
  return results;
});

