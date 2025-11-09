import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:handyman_provider_flutter/networks/network_utils.dart';

class PushApi {
  static Future<void> register({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    final url = buildBaseUrl('push/register');
    final headers = buildHeaderTokens();
    final body = {
      'token': token,
      'platform': platform,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    };
    final res = await http.post(url, headers: headers, body: jsonEncode(body));
    await handleResponse(res);
  }

  static Future<void> unregister({
    required String token,
  }) async {
    final url = buildBaseUrl('push/unregister');
    final headers = buildHeaderTokens();
    final body = {
      'token': token,
    };
    final res = await http.post(url, headers: headers, body: jsonEncode(body));
    await handleResponse(res);
  }
}


