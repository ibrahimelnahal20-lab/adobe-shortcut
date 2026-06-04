import '../../../core/models/shortcut_model.dart';
import 'shortcuts_search_service.dart';

class ClientSearchService implements ShortcutsSearchService {
  final List<ShortcutModel> allShortcuts;

  ClientSearchService({required this.allShortcuts});

  @override
  Future<List<ShortcutModel>> search({
    required String query,
    required String? platform,
    required String? appSlug,
  }) async {
    // In-memory search is fast enough to be synchronous, but we return a Future
    // to match the async interface required for future external search integrations.
    
    var results = allShortcuts;

    // 1. App Filter
    if (appSlug != null && appSlug.isNotEmpty && appSlug.toLowerCase() != 'all') {
      results = results.where((s) => s.app.toLowerCase() == appSlug.toLowerCase()).toList();
    }

    // 2. Query Filter (Smart Search: Text + Key)
    if (query.trim().isNotEmpty) {
      final normalizedQuery = _normalizeKeyString(query);
      final queryTokens = _tokenize(normalizedQuery);

      results = results.where((s) {
        // Text Match
        final inFunction = s.function.toLowerCase().contains(query.toLowerCase());
        final inCategory = s.category.toLowerCase().contains(query.toLowerCase());
        final inApp = s.app.toLowerCase().contains(query.toLowerCase());

        if (inFunction || inCategory || inApp) return true;

        // Key Match (Order-insensitive)
        final windowsKeys = _tokenize(_normalizeKeyString(s.windows));
        final macKeys = _tokenize(_normalizeKeyString(s.mac));

        bool matchWindows = false;
        bool matchMac = false;

        if (platform == 'windows' || platform == 'both' || platform == null) {
          matchWindows = _isTokensSubset(queryTokens, windowsKeys);
        }
        if (platform == 'macOS' || platform == 'both' || platform == null) {
          matchMac = _isTokensSubset(queryTokens, macKeys);
        }

        return matchWindows || matchMac;
      }).toList();
    }

    // 3. Platform Verification (Filter out empty shortcuts for specific platforms if needed)
    // Actually, if a user selects Windows, we just display Windows shortcuts. 
    // We don't filter out unless BOTH windows and mac are empty, which shouldn't happen.
    
    return results;
  }

  /// Normalizes a key string (e.g., "Ctrl + Shift + S" -> "ctrl shift s")
  String _normalizeKeyString(String input) {
    return input.toLowerCase().replaceAll('+', ' ').replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Tokenizes a normalized key string into a set of words
  Set<String> _tokenize(String normalizedInput) {
    if (normalizedInput.isEmpty) return {};
    return normalizedInput.split(' ').where((t) => t.isNotEmpty).toSet();
  }

  /// Checks if all query tokens are present in the target tokens (order-insensitive)
  bool _isTokensSubset(Set<String> queryTokens, Set<String> targetTokens) {
    if (queryTokens.isEmpty) return false;
    if (targetTokens.isEmpty) return false;
    
    for (final token in queryTokens) {
      if (!targetTokens.contains(token)) {
        return false;
      }
    }
    return true;
  }
}
