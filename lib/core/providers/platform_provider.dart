import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_provider.dart';

class PlatformNotifier extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString('platform');
  }

  void setPlatform(String? platform) {
    state = platform;
    final prefs = ref.read(sharedPreferencesProvider);
    if (platform != null) {
      prefs.setString('platform', platform);
    } else {
      prefs.remove('platform');
    }
  }
}

final platformProvider = NotifierProvider<PlatformNotifier, String?>(PlatformNotifier.new);
