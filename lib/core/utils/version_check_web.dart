// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

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
  debugPrint('Reload Triggered');
  try {
    final sw = html.window.navigator.serviceWorker;
    if (sw != null) {
      final registrations = await sw.getRegistrations();
      bool waitingExists = false;
      
      for (final reg in registrations) {
        if (reg.waiting != null) {
          waitingExists = true;
          debugPrint('Waiting Service Worker Found');
          
          final completer = Completer<void>();
          void listener(html.Event event) {
            debugPrint('Controller Changed');
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
          sw.addEventListener('controllerchange', listener);
          
          reg.waiting!.postMessage('skipWaiting');
          debugPrint('skipWaiting Sent');
          
          // Wait for the new service worker to take control
          try {
            await completer.future.timeout(const Duration(seconds: 3));
          } catch (e) {
            // Proceed even if it times out just in case
          }
          sw.removeEventListener('controllerchange', listener);
          
          await _clearCaches();
          debugPrint('New Version Loaded');
          html.window.location.reload();
          return;
        }
      }
      
      if (!waitingExists) {
        for (final reg in registrations) {
          await reg.update();
        }
      }
    }
  } catch (e) {
    // Ignore error
  }

  await _clearCaches();
  debugPrint('New Version Loaded');
  html.window.location.reload();
}

Future<void> _clearCaches() async {
  try {
    final cacheKeys = await html.window.caches?.keys();
    if (cacheKeys != null) {
      for (final key in cacheKeys) {
        await html.window.caches?.delete(key);
      }
    }
  } catch (_) {}
}
