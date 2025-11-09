import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_home_fragment.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_profile_fragment.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_list_screen.dart';
import 'package:handyman_provider_flutter/screens/chat/frobster_conversation_list_screen.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';

import '../booking_filter/booking_filter_screen.dart';
import '../components/image_border_component.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final int? index;

  ProviderDashboardScreen({this.index});

  @override
  ProviderDashboardScreenState createState() => ProviderDashboardScreenState();
}

class ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int currentIndex = 0;

  DateTime? currentBackPressTime;

  int _chatUnread = 0;

  List<Widget> fragmentList = [
    ProviderHomeFragment(),
    BookingFragment(),
    JobListScreen(fromDashboard: true),
    FrobsterConversationListScreen(),
    ProviderProfileFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(
      () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
        }

        window.onPlatformBrightnessChanged = () async {
          if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
            appStore
                .setDarkMode(context.platformBrightness() == Brightness.light);
          }
        };

        // Initial chat unread fetch
        _refreshChatUnread();

        // Refresh chat unread on push or other events
        LiveStream().on(LIVESTREAM_UPDATE_CHAT_UNREAD, (p0) {
          _refreshChatUnread();
        });
      },
    );

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });

    // await 3.seconds.delay;
    // if (getBoolAsync(FORCE_UPDATE_PROVIDER_APP)) {
    //   showForceUpdateDialog(context);
    // }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_PROVIDER_ALL_BOOKING);
    LiveStream().dispose(LIVESTREAM_UPDATE_CHAT_UNREAD);
  }

  Future<void> _refreshChatUnread() async {
    try {
      final res = await FrobsterChatApi.getUnreadSummary();
      final total = res.totalUnread;
      if (mounted) setState(() => _chatUnread = total);
    } catch (e) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: languages.lblCloseAppMsg,
      child: Scaffold(
        appBar: appBarWidget(
          [
            languages.providerHome,
            languages.lblBooking,
            languages.lblJob,
            languages.lblChat,
            languages.lblProfile,
          ][currentIndex],
          color: primaryColor,
          textColor: Colors.white,
          showBack: false,
          actions: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  ic_notification.iconImage(color: white, size: 20),
                  Positioned(
                    top: -14,
                    right: -6,
                    child: Observer(
                      builder: (context) {
                        if (appStore.notificationCount.validate() > 0)
                          return Container(
                            padding: EdgeInsets.all(4),
                            child: FittedBox(
                              child: Text(appStore.notificationCount.toString(),
                                  style: primaryTextStyle(
                                      size: 12, color: Colors.white)),
                            ),
                            decoration: boxDecorationDefault(
                                color: Colors.red, shape: BoxShape.circle),
                          );

                        return Offstage();
                      },
                    ),
                  )
                ],
              ),
              onPressed: () async {
                NotificationFragment().launch(context);
              },
            ),
            if (currentIndex == 1)
              IconButton(
                icon: ic_filter.iconImage(color: white, size: 22),
                onPressed: () async {
                  BookingFilterScreen(showHandymanFilter: true)
                      .launch(context)
                      .then((value) {
                    if (value != null) {
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                    }
                  });
                },
              ),
          ],
        ),
        body: fragmentList[currentIndex],
        bottomNavigationBar: Blur(
          blur: 30,
          borderRadius: radius(0),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.primaryColor.withValues(alpha: 0.02),
              indicatorColor: context.primaryColor.withValues(alpha: 0.1),
              labelTextStyle:
                  WidgetStateProperty.all(primaryTextStyle(size: 12)),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              destinations: [
                NavigationDestination(
                  icon: ic_home.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      ic_fill_home.iconImage(color: context.primaryColor),
                  label: languages.home,
                ),
                NavigationDestination(
                  icon: total_booking.iconImage(color: appTextSecondaryColor),
                  selectedIcon:
                      fill_ticket.iconImage(color: context.primaryColor),
                  label: languages.lblBooking,
                ),
                NavigationDestination(
                  icon: rateUs.iconImage(color: appTextSecondaryColor),
                  selectedIcon: ic_star_fill.iconImage(color: context.primaryColor),
                  label: languages.lblJob,
                ),
                NavigationDestination(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(chat, height: 20, width: 20, color: appTextSecondaryColor),
                      if (_chatUnread > 0)
                        Positioned(
                          top: -8,
                          right: -10,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.rectangle, borderRadius: radius(10)),
                            child: Text(
                              _chatUnread.toString(),
                              style: primaryTextStyle(size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  selectedIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(ic_fill_textMsg, height: 26, width: 26),
                      if (_chatUnread > 0)
                        Positioned(
                          top: -6,
                          right: -8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.rectangle, borderRadius: radius(10)),
                            child: Text(
                              _chatUnread.toString(),
                              style: primaryTextStyle(size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: languages.lblChat,
                ),
                Observer(builder: (context) {
                  return NavigationDestination(
                    icon: (appStore.isLoggedIn &&
                            appStore.userProfileImage.isNotEmpty)
                        ? IgnorePointer(
                            ignoring: true,
                            child: ImageBorder(
                                src: appStore.userProfileImage, height: 26))
                        : profile.iconImage(color: appTextSecondaryColor),
                    selectedIcon: (appStore.isLoggedIn &&
                            appStore.userProfileImage.isNotEmpty)
                        ? IgnorePointer(
                            ignoring: true,
                            child: ImageBorder(
                                src: appStore.userProfileImage, height: 26))
                        : ic_fill_profile.iconImage(
                            color: context.primaryColor),
                    label: languages.lblProfile,
                  );
                }),
              ],
              onDestinationSelected: (index) {
                currentIndex = index;
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }
}
