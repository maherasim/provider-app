import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:handyman_provider_flutter/screens/chat/frobster_chat_thread_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart'; // ignore: unused_import
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/booking_detail_response.dart';
import '../utils/model_keys.dart';

class BasicInfoComponent extends StatefulWidget {
  final UserData? handymanData;
  final UserData? customerData;
  final UserData? providerData;
  final ServiceData? service;
  final BookingDetailResponse? bookingInfo;

  /// flag == 0 = customer
  /// flag == 1 = handyman
  /// else provider
  final int flag;
  final BookingData? bookingDetail;

  BasicInfoComponent(this.flag,
      {this.customerData,
      this.handymanData,
      this.providerData,
      this.service,
      this.bookingDetail,
      this.bookingInfo});

  @override
  BasicInfoComponentState createState() => BasicInfoComponentState();
}

class BasicInfoComponentState extends State<BasicInfoComponent> {
  UserData customer = UserData();
  UserData provider = UserData();
  UserData userData = UserData();
  ServiceData service = ServiceData();

  String? googleUrl;
  String? address;
  String? name;
  String? contactNumber;
  String? profileUrl;
  int? profileId;
  int? handymanRating;

  int? flag;

  bool isChattingAllow = false;

  bool showVerifiedBadge = false;

  bool showContactWidgets = false;

  bool showChat = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.flag == 0) {
      profileId = widget.customerData!.id.validate();
      name = widget.customerData!.displayName.validate();
      profileUrl = widget.customerData!.profileImage.validate();
      contactNumber = widget.customerData!.contactNumber.validate();
      address = widget.customerData!.address.validate();

      userData = widget.customerData!;
      await userService
          .getUser(email: widget.customerData!.email.validate())
          .then((value) {
        widget.customerData!.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
      showContactWidgets =
          widget.bookingDetail!.status != BookingStatusKeys.complete &&
              widget.bookingDetail!.status != BookingStatusKeys.cancelled;
      // Show chat only after advance payment is completed
      showChat = widget.bookingDetail?.isAdvancePaymentDone == true;
      showVerifiedBadge =
          widget.customerData!.isVerifiedAccount.validate().getBoolInt();
    } else if (widget.flag == 1) {
      profileId = widget.handymanData!.id.validate();
      name = widget.handymanData!.displayName.validate();
      profileUrl = widget.handymanData!.profileImage.validate();
      contactNumber = widget.handymanData!.contactNumber.validate();
      address = widget.handymanData!.address.validate();

      userData = widget.handymanData!;
      await userService
          .getUser(email: widget.handymanData!.email.validate())
          .then((value) {
        widget.handymanData!.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
      showContactWidgets = widget.bookingInfo != null &&
          widget.bookingInfo!.providerData!.id.validate() !=
              widget.handymanData!.id.validate();
      showVerifiedBadge =
          widget.handymanData!.isVerifiedAccount.validate().getBoolInt();
      // Show chat only after advance payment is completed and booking is active
      showChat = (widget.bookingDetail?.isAdvancePaymentDone == true) &&
          widget.bookingDetail!.status != BookingStatusKeys.complete &&
          widget.bookingDetail!.status != BookingStatusKeys.cancelled;
    } else {
      profileId = widget.providerData!.id.validate();
      name = widget.providerData!.displayName.validate();
      profileUrl = widget.providerData!.profileImage.validate();
      contactNumber = widget.providerData!.contactNumber.validate();
      address = widget.providerData!.address.validate();
      provider = widget.providerData!;
      showVerifiedBadge =
          widget.providerData!.isVerifiedAccount.validate().getBoolInt();
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final String memberSince = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(userData.createdAt.validate()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (profileUrl.validate().isNotEmpty)
              ImageBorder(src: profileUrl.validate(), height: 45),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HandymanNameWidget(
                      name: name.validate(),
                      size: 14,
                      showVerifiedBadge: showVerifiedBadge,
                    ).flexible(),
                  ],
                ),
                if (widget.flag == 1 &&
                    userData.handymanRating.validate().toDouble() > 0)
                  Row(
                    children: [
                      Icon(Icons.star, color: rattingColor, size: 16),
                      2.width,
                      Text('${userData.handymanRating.validate().toDouble()}',
                          style: secondaryTextStyle(weight: FontWeight.bold)),
                    ],
                  ),
              ],
            ).expand(),
            // Removed WhatsApp quick action
          ],
        ),
        if (widget.bookingDetail!.canCustomerContact && widget.flag == 0)
          Column(
            children: [
              16.height,
              if (userData.createdAt.validate().isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Since:',
                      style: boldTextStyle(
                          size: 12,
                          color: appStore.isDarkMode
                              ? textSecondaryColor
                              : textPrimaryColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.width,
                    Text(
                      memberSince,
                      style: boldTextStyle(
                          size: 12,
                          color:
                              appStore.isDarkMode ? white : textSecondaryColor,
                          weight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ).expand(flex: 4),
                  ],
                ).onTap(() {
                  launchMail(userData.email.validate());
                }),
              if (widget.bookingDetail != null) ...[
                8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${languages.lblAddress}:',
                      style: boldTextStyle(
                          size: 12,
                          color: appStore.isDarkMode
                              ? textSecondaryColor
                              : textPrimaryColor),
                    ).expand(),
                    8.width,
                    Builder(
                      builder: (context) {
                        final String city = userData.cityName.validate();
                        final String country = userData.countryName.validate();
                        final String locationText = [city, country].where((e) => e.isNotEmpty).join(' - ');
                        return Text(
                          locationText.isNotEmpty ? locationText : widget.bookingDetail!.address.validate(),
                          style: boldTextStyle(
                              size: 12,
                              color: appStore.isDarkMode ? white : textSecondaryColor,
                              weight: FontWeight.w400),
                          textAlign: TextAlign.left,
                        ).expand(flex: 4);
                      },
                    ),
                  ],
                )
                    .visible(true),
                8.height,
              ],
            ],
          ).paddingSymmetric(horizontal: 4),
        if (showChat) ...[
          16.height,
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                child: AppButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(chat,
                          color: Colors.white, height: 18, width: 18),
                      16.width,
                      Text(languages.lblChat,
                          style: boldTextStyle(color: Colors.white)),
                    ],
                  ),
                  width: context.width(),
                  elevation: 0,
                  color: Colors.transparent,
                  textStyle: boldTextStyle(color: white),
                  onTap: () async {
                  final receiverId = userData.id;
                  if (receiverId == null) {
                    toast(languages.somethingWentWrong);
                    return;
                  }
                  toast(languages.pleaseWaitWhileWeLoadChatDetails);
                  try {
                    final res = await FrobsterChatApi.openWithUser(userId: receiverId, title: 'Direct Message');
                    Fluttertoast.cancel();
                    if (res.status && res.conversationId != 0) {
                      FrobsterChatThreadScreen(
                        conversationId: res.conversationId,
                        title: 'Direct Message',
                        otherDisplayName: name,
                        otherAvatarUrl: profileUrl,
                      ).launch(context);
                    } else {
                      toast("${name.validate()} ${languages.isNotAvailableForChat}");
                    }
                  } catch (e) {
                    Fluttertoast.cancel();
                    toast(e.toString(), print: true);
                  }
                  },
                ),
              ).expand(),
            ],
          ),
        ],
      ],
    );
  }
}
