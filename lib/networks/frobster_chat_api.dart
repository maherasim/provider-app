import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:handyman_provider_flutter/models/frobster_chat_models.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';

class FrobsterChatApi {
  static Future<OpenChatResponse> openWithUser({
    required int userId,
    String title = 'Direct Message',
  }) async {
    final headers = buildHeaderTokens();
    final url = buildBaseUrl('chat/open-with-user');
    final response = await http.post(url, headers: headers, body: jsonEncode({'user_id': userId, 'title': title}));
    final res = await handleResponse(response);
    return OpenChatResponse.fromJson(Map<String, dynamic>.from(res));
  }

  static Future<MessagesResponse> fetchMessages({
    required int conversationId,
    int afterId = 0,
    int beforeId = 0,
    int limit = 50,
  }) async {
    final endpoint = 'chat/$conversationId/messages?after_id=$afterId&before_id=$beforeId&limit=$limit';
    final res = await handleResponse(await buildHttpResponse(endpoint));
    return MessagesResponse.fromJson(Map<String, dynamic>.from(res));
  }

  static Future<SendMessageResponse> sendMessage({
    required int conversationId,
    String? message,
    File? attachment,
  }) async {
    http.MultipartRequest multiPartRequest = await getMultiPartRequest('chat/$conversationId/send');

    if (message != null && message.trim().isNotEmpty) {
      multiPartRequest.fields['message'] = message.trim();
    }
    if (attachment != null) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    final completer = Completer<SendMessageResponse>();
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) {
        final obj = (data is String && data.isNotEmpty) ? jsonDecode(data) : {};
        completer.complete(SendMessageResponse.fromJson(Map<String, dynamic>.from(obj)));
      },
      onError: (err) {
        completer.completeError(err ?? 'Failed to send message');
      },
    );
    return completer.future;
  }

  static Future<void> markRead({
    required int conversationId,
    required int upToId,
  }) async {
    final headers = buildHeaderTokens();
    final url = buildBaseUrl('chat/$conversationId/read');
    final response = await http.post(url, headers: headers, body: jsonEncode({'up_to_id': upToId}));
    await handleResponse(response);
  }

  static String downloadAttachmentUrl(int messageId) {
    // BASE_URL already ends with /api/
    return '${BASE_URL}chat/download/$messageId';
  }

  static Future<ConversationListResponse> listConversations({required int page}) async {
    final res = await handleResponse(await buildHttpResponse('chat/conversations?page=$page'));
    return ConversationListResponse.fromJson(Map<String, dynamic>.from(res));
    }

  static Future<UnreadSummaryResponse> getUnreadSummary() async {
    final res = await handleResponse(await buildHttpResponse('chat/unread'));
    return UnreadSummaryResponse.fromJson(Map<String, dynamic>.from(res));
  }
}


