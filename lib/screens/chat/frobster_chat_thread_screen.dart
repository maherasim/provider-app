import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/frobster_chat_models.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';

class FrobsterChatThreadScreen extends StatefulWidget {
  final int conversationId;
  final String title;
  final String? otherDisplayName;
  final String? otherAvatarUrl;

  const FrobsterChatThreadScreen({
    super.key,
    required this.conversationId,
    this.title = 'Direct Message',
    this.otherDisplayName,
    this.otherAvatarUrl,
  });

  @override
  State<FrobsterChatThreadScreen> createState() => _FrobsterChatThreadScreenState();
}

class _FrobsterChatThreadScreenState extends State<FrobsterChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<FrobsterMessage> _messages = [];
  int _lastMessageId = 0;
  bool _loading = false;
  bool _loadingMore = false;
  Timer? _pollTimer;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchNew());
  }

  Future<void> _loadInitial() async {
    _safeSetState(() => _loading = true);
    try {
      final res = await FrobsterChatApi.fetchMessages(conversationId: widget.conversationId, limit: 50);
      _messages
        ..clear()
        ..addAll(res.messages);
      if (_messages.isNotEmpty) {
        _messages.sort((a, b) => a.id.compareTo(b.id));
        _lastMessageId = _messages.last.id;
        // Mark as read up to latest
        await FrobsterChatApi.markRead(conversationId: widget.conversationId, upToId: _lastMessageId);
        LiveStream().emit(LIVESTREAM_UPDATE_CHAT_UNREAD);
      }
      _safeSetState(() {});
      // Ensure we land at the bottom on initial open
      _scrollToBottom();
    } catch (e) {
      toast(e.toString(), print: true);
    } finally {
      _safeSetState(() => _loading = false);
    }
  }

  Future<void> _fetchNew() async {
    if (!mounted) return;
    if (_messages.isEmpty) {
      return _loadInitial();
    }
    try {
      final res = await FrobsterChatApi.fetchMessages(conversationId: widget.conversationId, afterId: _lastMessageId, limit: 50);
      if (res.messages.isNotEmpty) {
        _messages.addAll(res.messages);
        _messages.sort((a, b) => a.id.compareTo(b.id));
        _lastMessageId = _messages.last.id;
        await FrobsterChatApi.markRead(conversationId: widget.conversationId, upToId: _lastMessageId);
        LiveStream().emit(LIVESTREAM_UPDATE_CHAT_UNREAD);
        _safeSetState(() {});
        _scrollToBottom();
      }
    } catch (e) {
      // silent
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_messages.isEmpty || _loadingMore) return;
    _safeSetState(() => _loadingMore = true);
    try {
      final firstId = _messages.first.id;
      final res = await FrobsterChatApi.fetchMessages(conversationId: widget.conversationId, beforeId: firstId, limit: 50);
      if (res.messages.isNotEmpty) {
        _messages.insertAll(0, res.messages);
        _messages.sort((a, b) => a.id.compareTo(b.id));
        _safeSetState(() {});
      }
    } catch (e) {
      // silent
    } finally {
      _safeSetState(() => _loadingMore = false);
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (appStore.isLoading) return;
    appStore.setLoading(true);
    try {
      final res = await FrobsterChatApi.sendMessage(conversationId: widget.conversationId, message: text);
      _messageController.clear();
      if (res.flagged) {
        final types = res.piiTypes.join(', ');
        toast('Message hidden due to policy (${types.isEmpty ? 'policy' : types})');
      }
      await _fetchNew();
    } catch (e) {
      toast(e.toString(), print: true);
    } finally {
      appStore.setLoading(false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 64);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.otherDisplayName?.trim().isNotEmpty == true ? widget.otherDisplayName! : widget.title;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: widget.otherAvatarUrl.validate().isNotEmpty ? NetworkImage(widget.otherAvatarUrl!) : null,
              child: widget.otherAvatarUrl.validate().isNotEmpty
                  ? null
                  : Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: boldTextStyle(color: white, size: 12),
                    ),
            ),
            8.width,
            Expanded(child: Text(title, style: boldTextStyle(size: 16, color: white), overflow: TextOverflow.ellipsis)),
          ],
        ),
        backgroundColor: context.primaryColor,
        iconTheme: const IconThemeData(color: white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _loadMoreHistory,
                  child: _loading
                      ? const SizedBox()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final m = _messages[index];
                            final isMe = m.senderId == appStore.userId;
                            final bg = isMe ? context.primaryColor.withValues(alpha: 0.15) : context.cardColor;
                            final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                            final radius = isMe ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(2), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)) : const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));
                            return Column(
                              crossAxisAlignment: align,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: bg, borderRadius: radius),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: align,
                                    children: [
                                      if (m.hidden || m.policyViolation)
                                        Text(
                                          'Message hidden due to policy${m.piiTypes.isNotEmpty ? ' (${m.piiTypes.join(', ')})' : ''}',
                                          style: secondaryTextStyle(color: Colors.red, size: 12),
                                        ),
                                      if (!m.hidden && (m.message?.isNotEmpty == true))
                                        Text(m.message!, style: primaryTextStyle(size: 14)),
                                      if (!m.hidden && (m.attachment?.isNotEmpty == true))
                                        Text('Attachment', style: secondaryTextStyle(size: 12, color: context.primaryColor)),
                                      4.height,
                                      Text(m.createdAt, style: secondaryTextStyle(size: 10)),
                                    ],
                                  ),
                                ).paddingSymmetric(vertical: 4),
                              ],
                            );
                          },
                        ),
                ),
                Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
              ],
            ),
          ),
          Container(
            decoration: boxDecorationDefault(color: context.cardColor),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _messageController,
                      textFieldType: TextFieldType.MULTILINE,
                      maxLines: 3,
                      minLines: 1,
                      decoration: inputDecoration(context).copyWith(hintText: languages.lblMessage, hintStyle: secondaryTextStyle()),
                    ),
                  ),
                  8.width,
                  IconButton(
                    icon: Icon(Icons.send, color: context.primaryColor),
                    onPressed: _send,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


