import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/my_provider_widget.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_profile_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_list_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../booking_filter/booking_filter_screen.dart';
import '../components/image_border_component.dart';
import '../utils/app_configuration.dart';

class HandymanDashboardScreen extends StatefulWidget {
  final int? index;

  HandymanDashboardScreen({this.index});

  @override
  _HandymanDashboardScreenState createState() => _HandymanDashboardScreenState();
}

class _HandymanDashboardScreenState extends State<HandymanDashboardScreen> {
  int currentIndex = 0;

  List<Widget> fragmentList = [
    HandymanHomeFragment(),
    BookingFragment(),
    ChatListScreen(),
    HandymanProfileFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(primaryColor);

    afterBuildCreated(() async {
      if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      window.onPlatformBrightnessChanged = () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.light);
        }
      };
    });

    LiveStream().on(LIVESTREAM_CHANGE_HANDYMAN_TAB, (data) {
      currentIndex = (data as Map)["index"];

      setState(() {});

      100.milliseconds.delay.then((value) {
        if (data.containsKey('booking_type')) {
          LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, data['booking_type']);
        } else if (currentIndex == 1) {
          LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, '');
        }
      });
    });

    /*LiveStream().on(LIVESTREAM_HANDY_BOARD, (data) {
      currentIndex = (data as Map)["index"];
      LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, data['type']);
      setState(() {});
    });*/

    /*LiveStream().on(LIVESTREAM_HANDYMAN_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });*/

    await 3.seconds.delay;
    if (getBoolAsync(FORCE_UPDATE_PROVIDER_APP)) {
      showForceUpdateDialog(context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_CHANGE_HANDYMAN_TAB);
    // LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    // LiveStream().dispose(LIVESTREAM_HANDYMAN_ALL_BOOKING);
  }

  @override
  Widget build(BuildContext context) {
    Widget _gradientIcon(Widget icon) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return kAppPrimaryGradient
              .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
        },
        blendMode: BlendMode.srcIn,
        child: icon,
      );
    }
    return DoublePressBackWidget(
      message: languages.lblCloseAppMsg,
      child: Scaffold(
        body: fragmentList[currentIndex],
        appBar: AppBar(
          title: Text(
            [
              languages.handymanHome,
              languages.lblBooking,
              languages.lblChat,
              languages.lblProfile,
            ][currentIndex],
            style: boldTextStyle(color: Colors.white, size: APP_BAR_TEXT_SIZE),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace:
              Container(decoration: const BoxDecoration(gradient: kAppPrimaryGradient)),
          actions: [
            IconButton(
              icon: ic_info.iconImage(color: Colors.white),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(borderRadius: radius()),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (context) {
                    return MyProviderWidget();
                  },
                );
              },
            ),
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  ic_notification.iconImage(size: 20, color: white),
                  Positioned(
                    top: -10,
                    right: -4,
                    child: Observer(
                      builder: (context) {
                        if (appStore.notificationCount.validate() > 0)
                          return Container(
                            padding: EdgeInsets.all(4),
                            child: FittedBox(
                              child: Text(appStore.notificationCount.toString(), style: primaryTextStyle(size: 12, color: Colors.white)),
                            ),
                            decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.circle),
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
                  BookingFilterScreen(showHandymanFilter: true).launch(context).then((value) {
                    if (value != null) {
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                    }
                  });
                },
              ),
          ],
        ),
        bottomNavigationBar: Blur(
          blur: 30,
          borderRadius: radius(0),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.scaffoldBackgroundColor,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 12)),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              destinations: [
                NavigationDestination(
                  icon: ic_home.iconImage(color: appTextSecondaryColor),
                  selectedIcon: _gradientIcon(ic_fill_home.iconImage(color: Colors.white)),
                  label: languages.home,
                ),
                NavigationDestination(
                  icon: total_booking.iconImage(color: appTextSecondaryColor),
                  selectedIcon: _gradientIcon(fill_ticket.iconImage(color: Colors.white)),
                  label: languages.lblBooking,
                ),
                NavigationDestination(
                  icon: Image.asset(chat, height: 20, width: 20, color: appTextSecondaryColor),
                  selectedIcon: _gradientIcon(Image.asset(ic_fill_textMsg, height: 26, width: 26, color: Colors.white)),
                  label: languages.lblChat,
                ),
                Observer(builder: (context) {
                  return NavigationDestination(
                    icon: (appStore.isLoggedIn && appStore.userProfileImage.isNotEmpty) ? IgnorePointer(ignoring: true, child: ImageBorder(src: appStore.userProfileImage, height: 26)) : profile.iconImage(color: appTextSecondaryColor),
                    selectedIcon: (appStore.isLoggedIn && appStore.userProfileImage.isNotEmpty)
                        ? IgnorePointer(ignoring: true, child: ImageBorder(src: appStore.userProfileImage, height: 26))
                        : _gradientIcon(ic_fill_profile.iconImage(color: Colors.white)),
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
