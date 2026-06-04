import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../localization/localization_provider.dart';
import '../../shared/utils/toast_service.dart';
import '../../features/shortcuts/providers/shortcuts_providers.dart';
import '../../features/shortcuts/services/client_search_service.dart';
import '../models/shortcut_model.dart';
import '../../../core/providers/platform_provider.dart';
class BookmarksNotifier extends Notifier<List<String>> {
  static const _key = 'saved_shortcuts';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_key) ?? [];
  }

  void toggleBookmark(String id, BuildContext context, AppStrings strings) {
    final isBookmarked = state.contains(id);
    final prefs = ref.read(sharedPreferencesProvider);
    
    if (isBookmarked) {
      state = state.where((element) => element != id).toList();
      prefs.setStringList(_key, state);
      _showFeedback(context, strings.bookmarkRemoved);
    } else {
      state = [...state, id];
      prefs.setStringList(_key, state);
      _showFeedback(context, strings.bookmarkAdded);
    }
  }

  void _showFeedback(BuildContext context, String message) {
    AppToast.showSuccess(context, message);
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, List<String>>(() {
  return BookmarksNotifier();
});

class BookmarksSelectedAppNotifier extends Notifier<String> {
  @override
  String build() => 'all';
  void setApp(String app) => state = app;
}

final bookmarksSelectedAppProvider = NotifierProvider<BookmarksSelectedAppNotifier, String>(BookmarksSelectedAppNotifier.new);

final bookmarkedShortcutsProvider = FutureProvider<List<ShortcutModel>>((ref) async {
  final allShortcuts = await ref.watch(allShortcutsProvider.future);
  final bookmarks = ref.watch(bookmarksProvider);
  return allShortcuts.where((s) => bookmarks.contains(s.id)).toList();
});

final filteredBookmarkedShortcutsProvider = FutureProvider<List<ShortcutModel>>((ref) async {
  final bookmarkedShortcuts = await ref.watch(bookmarkedShortcutsProvider.future);
  final query = ref.watch(searchQueryProvider);
  final appSlug = ref.watch(bookmarksSelectedAppProvider);
  final platform = ref.watch(platformProvider);
  
  final searchService = ClientSearchService(allShortcuts: bookmarkedShortcuts);
  
  return await searchService.search(
    query: query,
    platform: platform,
    appSlug: appSlug == 'all' ? null : appSlug,
  );
});
