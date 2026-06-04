import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedTheme = prefs.getString('theme');
    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setTheme(ThemeMode theme) {
    state = theme;
    final prefs = ref.read(sharedPreferencesProvider);
    if (theme == ThemeMode.light) {
      prefs.setString('theme', 'light');
    } else if (theme == ThemeMode.dark) {
      prefs.setString('theme', 'dark');
    } else {
      prefs.remove('theme');
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
