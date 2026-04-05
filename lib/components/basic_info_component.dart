import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:handyman_provider_flutter/screens/chat/frobster_chat_thread_screen.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart'; // ignore: unused_import
import 'package:handyman_provider_flutter/utils/constant.dart';
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

  Widget _buildHandymanLocation() {
    // Use widget.handymanData directly to avoid async initialization issues
    final UserData? data = widget.handymanData ?? userData;
    final String city = data?.cityName.validate() ?? '';
    final String country = data?.countryName.validate() ?? '';
    final String locationText = [city, country].where((e) => e.isNotEmpty).join(' - ');
    
    // Always return the same widget structure to maintain stable tree
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        locationText.isNotEmpty ? locationText : '',
        style: secondaryTextStyle(size: 12, color: textSecondaryColorGlobal),
      ),
    ).visible(locationText.isNotEmpty);
  }

  Widget _buildHandymanRating() {
    // Use widget.handymanData directly to get rating
    final UserData? data = widget.handymanData ?? userData;
    final num? rating = data?.handymanRating;
    
    // Check if rating exists and is greater than 0
    if (rating == null || rating <= 0) {
      return SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          DisabledRatingBarWidget(
            rating: rating.toDouble(),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerLocation() {
    // Use widget.customerData directly to get city/country
    final UserData? data = widget.customerData ?? userData;
    final String city = data?.cityName.validate() ?? '';
    final String country = data?.countryName.validate() ?? '';
    final String locationText = [city, country].where((e) => e.isNotEmpty).join(' - ');
    
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        locationText.isNotEmpty ? locationText : '',
        style: secondaryTextStyle(size: 12, color: textSecondaryColorGlobal),
      ),
    ).visible(locationText.isNotEmpty);
  }

  Widget _buildCustomerRating() {
    // Use widget.customerData directly to get rating
    final UserData? data = widget.customerData ?? userData;
    final num? rating = data?.customerRating;
    final int? totalRatings = data?.customerTotalRatings;
    final List<CustomerReview>? customerReviews = data?.customerReviews;
    
    // Check if rating exists and is greater than 0
    if (rating == null || rating <= 0) {
      return SizedBox.shrink();
    }
    
    // Check if there are reviews with comments
    final bool hasReviews = customerReviews != null && 
        customerReviews.isNotEmpty && 
        customerReviews.any((r) => r.review.validate().isNotEmpty);
    
    final reviewsToShow = hasReviews ? customerReviews : null;
    
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          DisabledRatingBarWidget(
            rating: rating.toDouble(),
            size: 14,
          ),
          4.width,
          if (totalRatings != null && totalRatings > 0)
            GestureDetector(
              onTap: reviewsToShow != null
                  ? () => _showCustomerReviewsDialog(reviewsToShow)
                  : null,
              child: Text(
                '($totalRatings)',
                style: secondaryTextStyle(
                  size: 12,
                  color: hasReviews ? primaryColor : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomerReviewsDialog(List<CustomerReview> reviews) {
    final reviewsWithComments = reviews.where((r) => r.review.validate().isNotEmpty).toList();
    
    if (reviewsWithComments.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: context.height() * 0.7),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${languages.review} (${reviewsWithComments.length})',
                      style: boldTextStyle(size: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                16.height,
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: reviewsWithComments.length,
                    separatorBuilder: (context, index) => Divider(color: context.dividerColor, height: 24),
                    itemBuilder: (context, index) {
                      final review = reviewsWithComments[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (review.providerName != null) ...[
                            Row(
                              children: [
                                if (review.providerProfileImage.validate().isNotEmpty)
                                  CachedImageWidget(
                                    url: review.providerProfileImage!,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(15),
                                if (review.providerProfileImage.validate().isNotEmpty) 8.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.providerName.validate(),
                                        style: boldTextStyle(size: 14),
                                      ),
                                      if (review.rating != null) ...[
                                        4.height,
                                        Row(
                                          children: [
                                            DisabledRatingBarWidget(
                                              rating: review.rating!.toDouble(),
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (review.createdAt.validate().isNotEmpty)
                                  Text(
                                    formatDate(review.createdAt.validate(), format: DATE_FORMAT_4),
                                    style: secondaryTextStyle(size: 10),
                                  ),
                              ],
                            ),
                            8.height,
                          ],
                          Text(
                            review.review.validate(),
                            style: primaryTextStyle(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                16.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      languages.lblCancel,
                      style: boldTextStyle(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String memberSince = '';
    if (userData.id != null) {
      try {
        final String? createdAt = userData.createdAt;
        if (createdAt != null && createdAt.isNotEmpty) {
          final DateTime? parsedDate = DateTime.tryParse(createdAt);
          if (parsedDate != null) {
            memberSince = DateFormat('yyyy-MM-dd').format(parsedDate);
          }
        }
      } catch (e) {
        memberSince = '';
      }
    }

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
                if (widget.flag == 1)
                  _buildHandymanRating(),
                if (widget.flag == 1)
                  _buildHandymanLocation(),
                if (widget.flag == 0)
                  _buildCustomerLocation(),
                if (widget.flag == 0)
                  _buildCustomerRating(),
              ],
            ).expand(),
            // Removed WhatsApp quick action
          ],
        ),
        if (widget.bookingDetail!.canCustomerContact && widget.flag == 0)
          Column(
            children: [
              16.height,
              if (memberSince.isNotEmpty)
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
                        // Use widget.customerData directly to ensure we get the latest data
                        final UserData? customerData = widget.customerData ?? userData;
                        final String city = customerData?.cityName.validate() ?? '';
                        final String country = customerData?.countryName.validate() ?? '';
                        final String locationText = [city, country].where((e) => e.isNotEmpty).join(' - ');
                        return Text(
                          locationText.isNotEmpty ? locationText : languages.lblNa,
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
                    final res = await FrobsterChatApi.openWithUser(userId: receiverId, title: languages.lblDirectMessage);
                    Fluttertoast.cancel();
                    if (res.status && res.conversationId != 0) {
                      FrobsterChatThreadScreen(
                        conversationId: res.conversationId,
                        title: languages.lblDirectMessage,
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
