import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/shortcut_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/platform_provider.dart';
import '../../../core/localization/localization_provider.dart'; // For sharedPreferencesProvider
import '../../../core/providers/bookmarks_provider.dart';
import '../services/client_search_service.dart';

// 1. Fetch ALL shortcuts from Firestore once.
final allShortcutsProvider = FutureProvider<List<ShortcutModel>>((ref) async {
  final service = FirestoreService();
  return service.getAllShortcuts();
});

// 2. Search Query State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Search Mode State
enum SearchMode { text, keys }

class SearchModeNotifier extends Notifier<SearchMode> {
  @override
  SearchMode build() => SearchMode.text;
  
  void setMode(SearchMode mode) {
    if (state != mode) {
      state = mode;
      // When switching modes, we clear the current search query
      ref.read(searchQueryProvider.notifier).update('');
      ref.read(displayLimitProvider.notifier).reset();
    }
  }
}
final searchModeProvider = NotifierProvider<SearchModeNotifier, SearchMode>(SearchModeNotifier.new);

// Discovery Card State
class SmartSearchTipNotifier extends Notifier<bool> {
  static const _key = 'has_seen_smart_search_tip';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> dismiss() async {
    state = true;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
  }
}
final smartSearchTipDismissedProvider = NotifierProvider<SmartSearchTipNotifier, bool>(SmartSearchTipNotifier.new);

// Bookmarks Only Filter State
class BookmarksOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() {
    state = !state;
    ref.read(displayLimitProvider.notifier).reset();
  }
}
final bookmarksOnlyProvider = NotifierProvider<BookmarksOnlyNotifier, bool>(BookmarksOnlyNotifier.new);

// 3. Selected App State (null/'all' means no filter)
class SelectedAppNotifier extends Notifier<String?> {
  @override
  String? build() => 'all';
  void update(String? appSlug) => state = appSlug;
}
final selectedAppProvider = NotifierProvider<SelectedAppNotifier, String?>(SelectedAppNotifier.new);

// 4. Pagination Display Limit State
class DisplayLimitNotifier extends Notifier<int> {
  @override
  int build() => 20;
  void increment(int amount) => state += amount;
  void reset() => state = 20;
}
final displayLimitProvider = NotifierProvider<DisplayLimitNotifier, int>(DisplayLimitNotifier.new);

// 5. Filtered Shortcuts Provider
final filteredShortcutsProvider = FutureProvider<List<ShortcutModel>>((ref) async {
  final allShortcuts = await ref.watch(allShortcutsProvider.future);
  final query = ref.watch(searchQueryProvider);
  final appSlug = ref.watch(selectedAppProvider);
  
  final platform = ref.watch(platformProvider);

  final searchService = ClientSearchService(allShortcuts: allShortcuts);

  var results = await searchService.search(
    query: query,
    platform: platform,
    appSlug: appSlug,
  );

  final bookmarksOnly = ref.watch(bookmarksOnlyProvider);
  if (bookmarksOnly) {
    final bookmarks = ref.watch(bookmarksProvider);
    results = results.where((s) => bookmarks.contains(s.id)).toList();
  }

  return results;
});
