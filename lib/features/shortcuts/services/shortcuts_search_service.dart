import '../../../core/models/shortcut_model.dart';

abstract class ShortcutsSearchService {
  /// Searches shortcuts based on the query, platform, and selected app.
  /// 
  /// - [query]: The raw search string (could be text or keys).
  /// - [platform]: 'windows', 'macOS', or 'both'.
  /// - [appSlug]: The selected app slug (e.g., 'photoshop'), or 'all'/'null' for any app.
  Future<List<ShortcutModel>> search({
    required String query,
    required String? platform,
    required String? appSlug,
  });
}
