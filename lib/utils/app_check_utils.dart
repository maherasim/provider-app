import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';

String? _appCheckToken;

String? get cachedAppCheckToken => _appCheckToken;

Future<void> initializeAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );

    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      _appCheckToken = token;
      if (token != null && token.isNotEmpty) {
        log('Firebase App Check token updated');
      }
    });

    await refreshAppCheckToken();
  } catch (e) {
    log('initializeAppCheck error: $e');
  }
}

Future<String?> refreshAppCheckToken({bool forceRefresh = false}) async {
  try {
    final token = await FirebaseAppCheck.instance.getToken(forceRefresh);
    if (token != null && token.isNotEmpty) {
      _appCheckToken = token;
    }
  } catch (e) {
    log('refreshAppCheckToken error: $e');
  }

  return _appCheckToken;
}
