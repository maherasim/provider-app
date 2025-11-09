
class OpenChatResponse {
  final bool status;
  final int conversationId;
  final bool existing;

  OpenChatResponse({
    required this.status,
    required this.conversationId,
    required this.existing,
  });

  factory OpenChatResponse.fromJson(Map<String, dynamic> json) {
    return OpenChatResponse(
      status: json['status'] == true,
      conversationId: (json['conversation_id'] ?? 0) is int ? json['conversation_id'] : int.tryParse('${json['conversation_id']}') ?? 0,
      existing: json['existing'] == true,
    );
  }
}

class SendMessageResponse {
  final bool status;
  final int id;
  final bool flagged;
  final List<String> piiTypes;

  SendMessageResponse({
    required this.status,
    required this.id,
    required this.flagged,
    required this.piiTypes,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      status: json['status'] == true,
      id: (json['id'] ?? 0) is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      flagged: json['flagged'] == true,
      piiTypes: (json['pii_types'] as List?)?.map((e) => '$e').toList() ?? <String>[],
    );
  }
}

class FrobsterMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? message;
  final String createdAt;
  final bool read;
  final String? attachment;
  final bool policyViolation;
  final bool hidden;
  final List<String> piiTypes;

  FrobsterMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.message,
    required this.createdAt,
    required this.read,
    required this.attachment,
    required this.policyViolation,
    required this.hidden,
    required this.piiTypes,
  });

  factory FrobsterMessage.fromJson(Map<String, dynamic> json) {
    return FrobsterMessage(
      id: (json['id'] ?? 0) is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      senderId: (json['sender_id'] ?? 0) is int ? json['sender_id'] : int.tryParse('${json['sender_id']}') ?? 0,
      senderName: json['sender_name']?.toString() ?? '',
      senderAvatarUrl: json['sender_avatar_url']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      read: json['read'] == true,
      attachment: json['attachment']?.toString(),
      policyViolation: json['policy_violation'] == true,
      hidden: json['hidden'] == true,
      piiTypes: (json['pii_types'] as List?)?.map((e) => '$e').toList() ?? <String>[],
    );
  }
}

class MessagesResponse {
  final bool status;
  final List<FrobsterMessage> messages;

  MessagesResponse({
    required this.status,
    required this.messages,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final List list = (json['messages'] as List?) ?? const [];
    return MessagesResponse(
      status: json['status'] == true,
      messages: list.map((e) => FrobsterMessage.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class ConversationUser {
  final int id;
  final String displayName;
  final String? avatarUrl;
  final String? userType;

  ConversationUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.userType,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    final intId = (json['id'] ?? 0) is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
    final name = json['display_name']?.toString() ?? json['name']?.toString() ?? '';
    return ConversationUser(
      id: intId,
      displayName: name,
      avatarUrl: json['avatar_url']?.toString(),
      userType: json['user_type']?.toString(),
    );
  }
}

class ConversationLastMessage {
  final int id;
  final String preview;
  final String createdAt;
  final bool read;

  ConversationLastMessage({
    required this.id,
    required this.preview,
    required this.createdAt,
    required this.read,
  });

  factory ConversationLastMessage.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessage(
      id: (json['id'] ?? 0) is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      preview: json['preview']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      read: json['read'] == true,
    );
  }

  /// Build from flat snippet fields in alternative response
  factory ConversationLastMessage.fromSnippet({
    required String preview,
    required String createdAt,
  }) {
    return ConversationLastMessage(
      id: 0,
      preview: preview,
      createdAt: createdAt,
      read: true,
    );
  }
}

class ConversationItem {
  final int id;
  final String title;
  final ConversationUser otherUser;
  final ConversationLastMessage? lastMessage;
  final int unreadCount;

  ConversationItem({
    required this.id,
    required this.title,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    // Support both shapes: last_message {...} or last_snippet/last_at flat fields
    ConversationLastMessage? lm;
    if (json['last_message'] != null) {
      lm = ConversationLastMessage.fromJson(Map<String, dynamic>.from(json['last_message']));
    } else if (json['last_snippet'] != null || json['last_at'] != null) {
      lm = ConversationLastMessage.fromSnippet(
        preview: json['last_snippet']?.toString() ?? '',
        createdAt: json['last_at']?.toString() ?? '',
      );
    }

    return ConversationItem(
      id: (json['id'] ?? 0) is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      otherUser: ConversationUser.fromJson(Map<String, dynamic>.from(json['other_user'] ?? {})),
      lastMessage: lm,
      unreadCount: (json['unread_count'] ?? 0) is int ? json['unread_count'] : int.tryParse('${json['unread_count']}') ?? 0,
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: (json['current_page'] ?? 1) is int ? json['current_page'] : int.tryParse('${json['current_page']}') ?? 1,
      lastPage: (json['last_page'] ?? 1) is int ? json['last_page'] : int.tryParse('${json['last_page']}') ?? 1,
      perPage: (json['per_page'] ?? 20) is int ? json['per_page'] : int.tryParse('${json['per_page']}') ?? 20,
      total: (json['total'] ?? 0) is int ? json['total'] : int.tryParse('${json['total']}') ?? 0,
    );
  }

  /// Build from top-level fields: page, per_page, total (compute last_page)
  factory Pagination.fromTopLevel({
    required int page,
    required int perPage,
    required int total,
  }) {
    final last = perPage > 0 ? ((total + perPage - 1) ~/ perPage) : 1;
    return Pagination(currentPage: page, lastPage: last, perPage: perPage, total: total);
  }
}

class ConversationListResponse {
  final bool status;
  final List<ConversationItem> data;
  final Pagination? pagination;

  ConversationListResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    // Handle both shapes:
    // 1) { status, data: [...], pagination: {...} }
    // 2) { status, page, per_page, total, items: [...] }
    final List list = (json['data'] as List?) ??
        (json['items'] as List?) ??
        const [];
    Pagination? p;
    if (json['pagination'] != null) {
      p = Pagination.fromJson(Map<String, dynamic>.from(json['pagination']));
    } else if (json.containsKey('page') || json.containsKey('per_page') || json.containsKey('total')) {
      final page = (json['page'] ?? 1) is int ? json['page'] : int.tryParse('${json['page']}') ?? 1;
      final per = (json['per_page'] ?? 20) is int ? json['per_page'] : int.tryParse('${json['per_page']}') ?? 20;
      final tot = (json['total'] ?? 0) is int ? json['total'] : int.tryParse('${json['total']}') ?? 0;
      p = Pagination.fromTopLevel(page: page, perPage: per, total: tot);
    }

    return ConversationListResponse(
      status: json['status'] == true,
      data: list.map((e) => ConversationItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      pagination: p,
    );
  }
}

class UnreadByConversation {
  final int conversationId;
  final int unread;

  UnreadByConversation({required this.conversationId, required this.unread});

  factory UnreadByConversation.fromJson(Map<String, dynamic> json) {
    return UnreadByConversation(
      conversationId: (json['conversation_id'] ?? 0) is int ? json['conversation_id'] : int.tryParse('${json['conversation_id']}') ?? 0,
      unread: (json['unread'] ?? 0) is int ? json['unread'] : int.tryParse('${json['unread']}') ?? 0,
    );
  }
}

class UnreadSummaryResponse {
  final bool status;
  final int totalUnread;
  final List<UnreadByConversation> byConversation;

  UnreadSummaryResponse({
    required this.status,
    required this.totalUnread,
    required this.byConversation,
  });

  factory UnreadSummaryResponse.fromJson(Map<String, dynamic> json) {
    final List list = (json['by_conversation'] as List?) ?? const [];
    return UnreadSummaryResponse(
      status: json['status'] == true,
      totalUnread: (json['total_unread'] ?? 0) is int ? json['total_unread'] : int.tryParse('${json['total_unread']}') ?? 0,
      byConversation: list.map((e) => UnreadByConversation.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}


