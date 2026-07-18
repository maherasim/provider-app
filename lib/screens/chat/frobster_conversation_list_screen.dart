import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/frobster_chat_models.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:handyman_provider_flutter/screens/chat/frobster_chat_thread_screen.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';

class FrobsterConversationListScreen extends StatefulWidget {
  const FrobsterConversationListScreen({super.key});

  @override
  State<FrobsterConversationListScreen> createState() => _FrobsterConversationListScreenState();
}

class _FrobsterConversationListScreenState extends State<FrobsterConversationListScreen> {
  final List<ConversationItem> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = false;
  bool _initial = true;
  bool _hasError = false;
  String? _errorMessage;
  final ScrollController _controller = ScrollController();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _disposed = false;
    log('FrobsterConversationListScreen initState called');
    _controller.addListener(_onScroll);
    LiveStream().on(LIVESTREAM_UPDATE_CHAT_UNREAD, (p0) {
      // Guard with _disposed flag so stale listeners from prior state instances
      // (nb_utils LiveStream has no per-listener removal) do nothing after dispose.
      if (_disposed || !mounted) return;
      log('LIVESTREAM_UPDATE_CHAT_UNREAD received, refreshing chat list');
      _fetch(page: 1, refresh: true);
    });
    // Call fetch immediately and also after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('FrobsterConversationListScreen postFrameCallback, calling _fetch');
      if (mounted) _fetch(page: 1);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    // Do NOT call LiveStream().dispose(LIVESTREAM_UPDATE_CHAT_UNREAD) here —
    // that would also remove the dashboard's listener for the same key.
    // The _disposed flag above prevents stale callbacks from doing anything.
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      if (!_loading && _page < _lastPage) {
        _fetch(page: _page + 1);
      }
    }
  }

  Future<void> _fetch({required int page, bool refresh = false}) async {
    if (_loading) {
      log('Chat fetch already in progress, skipping...');
      return;
    }
    if (!mounted) {
      log('Widget not mounted, skipping fetch');
      return;
    }
    log('Fetching conversations page: $page');
    if (mounted) {
      setState(() {
        _loading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }
    try {
      log('Calling FrobsterChatApi.listConversations with page: $page');
      final res = await FrobsterChatApi.listConversations(page: page);
      if (!mounted) return;
      log('Received ${res.data.length} conversations');
      if (refresh || page == 1) _items.clear();
      _items.addAll(res.data);
      _page = res.pagination?.currentPage ?? page;
      _lastPage = res.pagination?.lastPage ?? _lastPage;
      log('Updated items count: ${_items.length}, current page: $_page, last page: $_lastPage');
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = null;
        });
      }
    } catch (e, stackTrace) {
      log('Error fetching conversations: $e');
      log('Stack trace: $stackTrace');
      final errorMsg = e.toString();
      if (mounted) {
        toast(errorMsg, print: true);
        setState(() {
          _hasError = true;
          _errorMessage = errorMsg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _initial = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _fetch(page: 1, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure fetch is called if not already called
    if (_initial && !_loading && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _initial && !_loading) {
          log('FrobsterConversationListScreen build - triggering initial fetch');
          _fetch(page: 1);
        }
      });
    }
    
    if (_initial && _loading) return LoaderWidget();
    
    if (_hasError && _items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: NoDataWidget(
            title: _errorMessage ?? languages.somethingWentWrong,
            imageWidget: ErrorStateWidget(),
            retryText: languages.reload,
            onRetry: () {
              _fetch(page: 1, refresh: true);
            },
          ).paddingAll(16).center().withHeight(context.height() - 100),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _items.isEmpty && !_loading
          ? SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: NoDataWidget(
                title: languages.noConversation,
                subTitle: languages.noConversationSubTitle,
                imageWidget: EmptyStateWidget(),
              ).paddingAll(16).center().withHeight(context.height() - 100),
            )
          : ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.all(12),
              itemCount: _items.length + (_page < _lastPage ? 1 : 0),
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: LoaderWidget()),
                  );
                }
                final item = _items[index];
                final name = item.otherUser.displayName;
                final subtitle = item.lastMessage?.preview ?? '';
                final time = item.lastMessage?.createdAt ?? '';
                return InkWell(
                  borderRadius: radius(16),
                  onTap: () {
                    FrobsterChatThreadScreen(
                      conversationId: item.id,
                      title: item.title,
                      otherDisplayName: item.otherUser.displayName,
                      otherAvatarUrl: item.otherUser.avatarUrl,
                    ).launch(context);
                  },
                  child: Container(
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: context.cardColor,
                      borderRadius: radius(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: kAppPrimaryGradient,
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: context.cardColor,
                            backgroundImage: item.otherUser.avatarUrl.validate().isNotEmpty ? NetworkImage(item.otherUser.avatarUrl!) : null,
                            child: item.otherUser.avatarUrl.validate().isNotEmpty ? null : Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: boldTextStyle()),
                          ),
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(name, style: boldTextStyle(), overflow: TextOverflow.ellipsis)),
                                  8.width,
                                  Text(time, style: secondaryTextStyle(size: 10)),
                                ],
                              ),
                              4.height,
                              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()),
                            ],
                          ),
                        ),
                        if (item.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(12)),
                            child: Text('${item.unreadCount}', style: primaryTextStyle(color: white, size: 10)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


