import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/constant.dart';
import '../utils/firebase_messaging_utils.dart';
import '../utils/images.dart';

class SwitchPushNotificationSubscriptionComponent extends StatefulWidget {
  const SwitchPushNotificationSubscriptionComponent({Key? key}) : super(key: key);

  @override
  State<SwitchPushNotificationSubscriptionComponent> createState() => _SwitchPushNotificationSubscriptionComponentState();
}

class _SwitchPushNotificationSubscriptionComponentState extends State<SwitchPushNotificationSubscriptionComponent> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return SettingItemWidget(
      leading: ic_notification.iconImage(size: appStore.userType == USER_TYPE_PROVIDER ? 16 : 18),
      title: languages.pushNotification,
      titleTextStyle: appStore.userType == USER_TYPE_PROVIDER ? boldTextStyle(size: 12) : primaryTextStyle(),
      padding: appStore.userType == USER_TYPE_PROVIDER ? null : EdgeInsets.all(16),
      decoration: appStore.userType == USER_TYPE_PROVIDER ? boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)) : null,
      trailing: Transform.scale(
        scale: appStore.userType == USER_TYPE_PROVIDER ? 0.6 : 0.7,
        child: Observer(builder: (context) {
          // Must use app session (isLoggedIn), not FirebaseAuth — backend login
          // may leave FirebaseAuth.currentUser null so the switch would stay off.
          return Switch.adaptive(
            value: appStore.isLoggedIn && appStore.isSubscribedForPushNotification,
            onChanged: (v) async {
              if (appStore.isLoading) return;
              appStore.setLoading(true);
              try {
                if (v) {
                  final result = await subscribeToFirebaseTopic();
                  if (result) {
                    toast(languages.pushNotification + " " + languages.enabled);
                  } else {
                    toast(languages.somethingWentWrong);
                  }
                } else {
                  await unsubscribeFirebaseTopic(appStore.userId);
                  toast(languages.pushNotification + " " + languages.disabled);
                }
              } catch (e) {
                toast(e.toString());
              } finally {
                appStore.setLoading(false);
                setState(() {});
              }
            },
          ).withHeight(18);
        }),
      ),
    );
  }
}
