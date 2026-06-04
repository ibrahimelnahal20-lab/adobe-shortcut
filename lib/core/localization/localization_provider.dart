import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';
import 'translations/en.dart';
import 'translations/ar.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class LocalizationNotifier extends Notifier<String> {
  static const _key = 'language';

  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final lang = prefs.getString(_key);
    return (lang == 'ar') ? 'ar' : 'en';
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'en' && lang != 'ar') return;
    state = lang;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, lang);
  }
}

final localizationProvider = NotifierProvider<LocalizationNotifier, String>(() {
  return LocalizationNotifier();
});

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(localizationProvider);
  return lang == 'ar' ? arStrings : enStrings;
});
