import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/localization_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/update_wrapper.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/constants/app_version.dart';


void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('Running Version: $appVersion');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localizationProvider);
    final isRtl = language == 'ar';

    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Adobe Shortcuts',
      theme: AppTheme.getLightTheme(language),
      darkTheme: AppTheme.getDarkTheme(language),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: UpdateWrapper(child: child!),
        );
      },
    );
  }
}
