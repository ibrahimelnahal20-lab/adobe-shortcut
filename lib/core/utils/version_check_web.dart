// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<String?> fetchServerVersion() async {
  try {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final url = '/version.json?t=$cacheBuster';
    final response = await html.HttpRequest.getString(url);
    final data = jsonDecode(response);
    return data['version'] as String?;
  } catch (e) {
    return null;
  }
}

Future<void> reloadPage() async {
  try {
    if (html.window.navigator.serviceWorker != null) {
      final registrations = await html.window.navigator.serviceWorker!.getRegistrations();
      bool waitingExists = false;
      
      for (final reg in registrations) {
        if (reg.waiting != null) {
          waitingExists = true;
          reg.waiting!.postMessage('skipWaiting');
        }
      }
      
      if (waitingExists) {
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        for (final reg in registrations) {
          await reg.update();
        }
      }
    }
  } catch (e) {
    await _fallbackCacheClear();
  }

  html.window.location.reload();
}

Future<void> _fallbackCacheClear() async {
  try {
    final cacheKeys = await html.window.caches?.keys();
    if (cacheKeys != null) {
      for (final key in cacheKeys) {
        await html.window.caches?.delete(key);
      }
    }
    final registrations = await html.window.navigator.serviceWorker?.getRegistrations();
    if (registrations != null) {
      for (final reg in registrations) {
        await reg.unregister();
      }
    }
  } catch (_) {}
}
