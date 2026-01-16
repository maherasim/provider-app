import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/assign_handyman_screen.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/user_data.dart';
import 'dotted_line.dart';
import 'image_border_component.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';

class BookingItemComponent extends StatefulWidget {
  final BookingData bookingData;
  final int? index;
  final bool showDescription;
  final bool isUpComingBooking;

  BookingItemComponent({
    required this.bookingData,
    this.index,
    this.showDescription = true,
    this.isUpComingBooking = false,
  });

  @override
  BookingItemComponentState createState() => BookingItemComponentState();
}

class BookingItemComponentState extends State<BookingItemComponent> {
  int page = 1;
  bool isLastPage = false;

  List<UserData> handymanList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  String buildTimeWidget({required BookingData bookingDetail}) {
    if (bookingDetail.bookingSlot == null) {
      return formatDate(bookingDetail.date.validate(), isTime: true);
    }
    return formatDate(
        getSlotWithDate(
            date: bookingDetail.date.validate(),
            slotTime: bookingDetail.bookingSlot.validate()),
        isTime: true);
  }

  Future<void> updateBooking(
      BookingData booking, String updatedStatus, int index) async {
    appStore.setLoading(true);
    Map request = {
      CommonKeys.id: booking.id,
      BookingUpdateKeys.status: updatedStatus,
      BookingUpdateKeys.paymentStatus: booking.isAdvancePaymentDone
          ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
          : booking.paymentStatus.validate(),
    };
    await bookingUpdate(request).then((res) async {
      setState(() {});
      // appStore.setLoading(false);
    }).catchError((e) {
      // appStore.setLoading(false);
    });
  }

  Future<void> confirmationRequestDialog(
      BuildContext context, int index, String status) async {
    if (status == BookingStatusKeys.rejected) {
      await _showGradientConfirmDialogItem(
        context: context,
        title: languages.confirmationRequestTxt,
        positiveText: languages.lblYes,
        negativeText: languages.lblNo,
        onAccept: () async {
          updateBooking(widget.bookingData, status, index);
        },
      );
    } else {
      showConfirmDialogCustom(
        context,
        title: languages.confirmationRequestTxt,
        positiveText: languages.lblYes,
        negativeText: languages.lblNo,
        primaryColor: primaryColor,
        onAccept: (context) async {
          updateBooking(widget.bookingData, status, index);
        },
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor:
            appStore.isDarkMode ? context.cardColor : cardLightColor,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.bookingData.isPackageBooking)
                CachedImageWidget(
                  url: widget.bookingData.bookingPackage!.imageAttachments
                          .validate()
                          .isNotEmpty
                      ? widget.bookingData.bookingPackage!.imageAttachments
                          .validate()
                          .first
                          .validate()
                      : "",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: defaultRadius,
                )
              else
                CachedImageWidget(
                  url: widget.bookingData.imageAttachments.validate().isNotEmpty
                      ? widget.bookingData.imageAttachments!.first.validate()
                      : '',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  radius: defaultRadius,
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: radius(16),
                              border: Border.all(color: context.primaryColor),
                            ),
                            child: Text(
                              '#${widget.bookingData.id.validate()}',
                              style: boldTextStyle(
                                  color: context.primaryColor, size: 12),
                            ),
                          ).flexible(),
                          5.width,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.bookingData.status
                                  .validate()
                                  .getBookingStatusBackgroundColor
                                  .withValues(alpha: 0.1),
                              borderRadius: radius(16),
                              border: Border.all(
                                  color: widget.bookingData.status
                                      .validate()
                                      .getBookingStatusBackgroundColor),
                            ),
                            child: Marquee(
                              child: Text(
                                widget.bookingData.status == BookingStatusKeys.accept &&
                                    (widget.bookingData.paymentStatus == null ||
                                        widget.bookingData.paymentStatus == '' ||
                                        widget.bookingData.paymentStatus == PENDING) ? 'Waiting for client advance payment' : widget.bookingData.status.validate().toBookingStatus(),
                                style: boldTextStyle(
                                  color: widget.bookingData.status
                                      .validate()
                                      .getBookingStatusBackgroundColor,
                                  size: 12,
                                ),
                              ),
                            ),
                          ).flexible(),
                          if (widget.bookingData.isPostJob)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color:
                                    context.primaryColor.withValues(alpha: 0.1),
                                border: Border.all(color: context.primaryColor),
                                borderRadius: radius(16),
                              ),
                              child: Text(
                                languages.postJob,
                                style: boldTextStyle(
                                    color: context.primaryColor, size: 12),
                              ),
                            ),
                          if (widget.bookingData.isPackageBooking)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color:
                                    context.primaryColor.withValues(alpha: 0.1),
                                border: Border.all(color: context.primaryColor),
                                borderRadius: radius(16),
                              ),
                              child: Text(
                                languages.package,
                                style: boldTextStyle(
                                    color: context.primaryColor, size: 12),
                              ),
                            ),
                        ],
                      ).flexible(),
                    ],
                  ),
                  12.height,
                  Marquee(
                    child: Text(
                      widget.bookingData.isPackageBooking
                          ? '${widget.bookingData.bookingPackage!.name.validate()}' 
                          : '${widget.bookingData.serviceName.validate()}',
                      style: boldTextStyle(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  8.height,
                  // City and Country
                  if (widget.bookingData.cityName.validate().isNotEmpty || 
                      widget.bookingData.countryName.validate().isNotEmpty)
                    Builder(
                      builder: (context) {
                        List<String> locationParts = [];
                        if (widget.bookingData.cityName.validate().isNotEmpty) {
                          locationParts.add(widget.bookingData.cityName.validate());
                        }
                        if (widget.bookingData.countryName.validate().isNotEmpty) {
                          locationParts.add(widget.bookingData.countryName.validate());
                        }
                        return Text(
                          locationParts.join(' - '),
                          style: secondaryTextStyle(size: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    ),
                  8.height,
                  if (widget.bookingData.bookingPackage != null)
                    PriceWidget(
                      price: widget.bookingData.totalAmount.validate(),
                      color: primaryColor,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PriceWidget(
                          isFreeService:
                              widget.bookingData.type == SERVICE_TYPE_FREE,
                          price: widget.bookingData.totalAmount.validate(),
                          color: primaryColor,
                          isHourlyService: widget.bookingData.isHourlyService,
                          isDailyService:
                              widget.bookingData.type == SERVICE_TYPE_DAILY,
                          isFixesService: widget.bookingData.isFixedService,
                          ),
                        if (widget.bookingData.discount.validate() != 0)
                          Text(
                            '(${widget.bookingData.discount.validate()}% ${languages.lblOff})',
                            style: boldTextStyle(size: 12, color: Colors.green),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).paddingLeft(4).expand(                        ),
                      ],
                    ),
                  // Job Type (Online/Onsite/Hybrid) - After Price
                  if (widget.bookingData.service?.visitType != null)
                    Builder(
                      builder: (context) {
                        String visitType = widget.bookingData.service!.visitType.validate();
                        String displayText = '';
                        if (visitType == VISIT_OPTION_ONLINE) {
                          displayText = languages.onlineRemoteService;
                        } else if (visitType == VISIT_OPTION_ON_SITE) {
                          displayText = languages.onSiteVisit;
                        } else if (visitType == VISIT_OPTION_HYBRID) {
                          displayText = 'Hybrid';
                        }
                        return displayText.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  displayText,
                                  style: secondaryTextStyle(size: 12, color: primaryColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )
                            : SizedBox.shrink();
                      },
                    ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
                  if (widget.showDescription)
          if (widget.showDescription)
            Container(
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor:
                    appStore.isDarkMode ? context.cardColor : whiteColor,
                border: Border.all(color: context.dividerColor),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.bookingData.address.validate().isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${languages.lblAddress}:',
                          style: secondaryTextStyle(),
                        ).expand(flex: 2),
                        8.width,
                        Marquee(
                          child: Text(
                            widget.bookingData.address.validate(),
                            style: boldTextStyle(size: 12),
                            textAlign: TextAlign.left,
                          ),
                        ).expand(flex: 5),
                      ],
                    ).paddingAll(8).visible(
                      // Hide address if payment status is pending by admin
                      widget.bookingData.paymentStatus != PENDING_BY_ADMINS
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${languages.lblDate} & ${languages.lblTime}:',
                        style: secondaryTextStyle(),
                      ).expand(flex: 2),
                      8.width,
                      Marquee(
                        child: Text(
                          "${formatDate(widget.bookingData.date.validate(), format: DATE_FORMAT_2)} ${languages.at} ${buildTimeWidget(bookingDetail: widget.bookingData)}",
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      ).expand(flex: 5),
                    ],
                  ).paddingOnly(left: 8, bottom: 8, right: 8),
                  if (widget.bookingData.customerName.validate().isNotEmpty)
                    Row(
                      children: [
                        Text(
                          '${languages.customer}:',
                          style: secondaryTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).expand(flex: 2),
                        8.width,
                        Marquee(
                          child: Text(
                            widget.bookingData.customerName.validate(),
                            style: boldTextStyle(size: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ).expand(flex: 5),
                      ],
                    ).paddingOnly(left: 8, bottom: 8, right: 8),
                  if (widget.bookingData.paymentStatus != null &&
                      widget.bookingData.status == BookingStatusKeys.complete)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${languages.paymentStatus}:',
                          style: secondaryTextStyle(),
                        ).expand(flex: 2),
                        8.width,
                        Marquee(
                          child: Text(
                            (() {
                              final String status = widget.bookingData.paymentStatus.validate();
                              final String methodRaw = widget.bookingData.paymentMethod.validate();
                              final String method = methodRaw.capitalizeFirstLetter();
                              if (methodRaw.toLowerCase() == 'bank_transfer' && widget.bookingData.bankTransferStatus == '0') {
                                return languages.waitingForPaymentApproval;
                              }
                              return buildPaymentStatusWithMethod(status, method);
                            })(),
                            style: boldTextStyle(
                              size: 12,
                              color: (widget.bookingData.paymentStatus.validate() == PAID)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ).expand(flex: 5),
                      ],
                    ).paddingOnly(left: 8, bottom: 8, right: 8),
                  if (widget.bookingData.handyman.validate().isNotEmpty &&
                      isUserTypeProvider)
                    Column(
                      children: [
                        DottedLine(
                          dashColor: appStore.isDarkMode
                              ? lightGray.withValues(alpha: 0.4)
                              : lightGray,
                          dashGapLength: 5,
                          dashLength: 8,
                        ).paddingAll(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageBorder(
                              src: widget.bookingData.handyman!.isEmpty
                                  ? widget.bookingData.providerImage.validate()
                                  : widget.bookingData.isProviderAndHandymanSame
                                      ? widget.bookingData.providerImage
                                          .validate()
                                      : widget.bookingData.handyman!.first
                                          .handyman!.handymanImage
                                          .validate(),
                              height: 40,
                            ),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Marquee(
                                      child: Text(
                                        widget.bookingData.handyman
                                            .validate()
                                            .first
                                            .handyman!
                                            .displayName
                                            .validate(),
                                        style: boldTextStyle(size: 12),
                                      ),
                                    ).flexible(),
                                    4.width,
                                    ImageIcon(
                                      AssetImage(ic_verified),
                                      size: 14,
                                      color: Colors.green,
                                    ).visible(
                                      widget.bookingData.handyman!.isEmpty
                                          ? widget.bookingData
                                                  .providerIsVerified
                                                  .validate() ==
                                              1
                                          : widget.bookingData
                                                  .isProviderAndHandymanSame
                                              ? widget.bookingData
                                                      .providerIsVerified
                                                      .validate() ==
                                                  1
                                              : widget
                                                      .bookingData
                                                      .handyman!
                                                      .first
                                                      .handyman!
                                                      .isVerifiedHandyman
                                                      .validate() ==
                                                  1,
                                    ),
                                  ],
                                ),
                                4.height,
                                Text(
                                  languages.handyman,
                                  style: secondaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ).flexible(),
                          ],
                        ).paddingAll(8),
                      ],
                    ),
                ],
              ).paddingAll(8),
            ),
          if (isUserTypeProvider && widget.bookingData.status == BookingStatusKeys.pending || (isUserTypeHandyman && widget.bookingData.status == BookingStatusKeys.accept))
            Row(
              children: [
                if (isUserTypeProvider)
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                    child: AppButton(
                      child: Text(languages.accept, style: boldTextStyle(color: white)),
                      width: context.width(),
                      color: Colors.transparent,
                      elevation: 0,
                      onTap: () async {
                        /// If Auto Assign is enabled, Assign to current Provider it self
                        if (appConfigurationStore.autoAssignStatus) {
                          await showInDialog(
                            context,
                            contentPadding: EdgeInsets.all(0),
                            builder: (_) {
                              return Container(
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(languages.lblAreYouSureYouWantToAssignToYourself, style: boldTextStyle()),
                                    16.height,
                                    Row(
                                      children: [
                                        AppButton(
                                          text: languages.lblCancel,
                                          elevation: 0,
                                          color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                                          textColor: textPrimaryColorGlobal,
                                          onTap: () {
                                            finish(context);
                                          },
                                        ).expand(),
                                        16.width,
                                        DecoratedBox(
                                          decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                                          child: AppButton(
                                            text: languages.lblYes,
                                            elevation: 0,
                                            color: Colors.transparent,
                                            textStyle: boldTextStyle(color: white),
                                            onTap: () async {
                                              finish(context);
                                              var request = {
                                                CommonKeys.id: widget.bookingData.id.validate(),
                                                CommonKeys.handymanId: [
                                                  appStore.userId.validate()
                                                ],
                                              };

                                              appStore.setLoading(true);

                                              await assignBooking(request).then((res) async {
                                                appStore.setLoading(false);

                                                setState(() {});
                                                LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);

                                                toast(res.message);
                                              }).catchError((e) {
                                                appStore.setLoading(false);

                                                toast(e.toString());
                                              });
                                            },
                                          ),
                                        ).expand(),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          await showInDialog(
                            context,
                            contentPadding: EdgeInsets.all(0),
                            builder: (_) {
                              return Container(
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(languages.wouldYouLikeToAssignThisBooking, style: boldTextStyle()),
                                    16.height,
                                    Row(
                                      children: [
                                        AppButton(
                                          text: languages.lblNo,
                                          elevation: 0,
                                          color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                                          textColor: textPrimaryColorGlobal,
                                          onTap: () {
                                            finish(context);
                                          },
                                        ).expand(),
                                        16.width,
                                        DecoratedBox(
                                          decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                                          child: AppButton(
                                            text: languages.lblYes,
                                            elevation: 0,
                                            color: Colors.transparent,
                                            textStyle: boldTextStyle(color: white),
                                            onTap: () async {
                                              finish(context);
                                              var request = {
                                                CommonKeys.id: widget.bookingData.id.validate(),
                                                BookingUpdateKeys.status:
                                                    BookingStatusKeys.accept,
                                                BookingUpdateKeys.paymentStatus: widget
                                                        .bookingData.isAdvancePaymentDone
                                                    ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                                                    : widget.bookingData.paymentStatus.validate(),
                                              };
                                              appStore.setLoading(true);

                                              bookingUpdate(request).then((res) async {
                                                setState(() {});
                                                LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                                              }).catchError((e) {
                                                appStore.setLoading(false);
                                                toast(e.toString());
                                              });
                                            },
                                          ),
                                        ).expand(),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ).expand(),
                12.width,
                AppButton(
                  child: Text(languages.decline, style: boldTextStyle()),
                  width: context.width(),
                  elevation: 0,
                  color: appStore.isDarkMode
                      ? context.scaffoldBackgroundColor
                      : white,
                  onTap: () {
                    if (isUserTypeProvider) {
                      confirmationRequestDialog(
                          context, widget.index!, BookingStatusKeys.rejected);
                    } else {
                      confirmationRequestDialog(
                          context, widget.index!, BookingStatusKeys.pending);
                    }
                  },
                ).expand(),
              ],
            ).paddingOnly(bottom: 8, left: 8, right: 8, top: 16),
          if (isUserTypeProvider && widget.bookingData.status == BookingStatusKeys.accept && widget.bookingData.paymentStatus == SERVICE_PAYMENT_STATUS_ADVANCE_PAID)
            Column(
              children: [
                8.height,
                DecoratedBox(
                  decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                  child: AppButton(
                    width: context.width(),
                    child: Text(
                      widget.bookingData.handyman!.isEmpty
                          ? languages.lblAssign
                          : languages.lblReassign,
                      style: boldTextStyle(color: white),
                    ),
                    color: Colors.transparent,
                    elevation: 0,
                    onTap: () {
                      AssignHandymanScreen(
                        bookingId: widget.bookingData.id,
                        serviceAddressId: widget.bookingData.bookingAddressId,
                        onUpdate: () {
                          setState(() {});
                          LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                        },
                      ).launch(context);
                    },
                  ),
                ),
              ],
            ).paddingAll(8),
        ],
      ), //booking card change
    ).onTap(
      () async {
        BookingDetailScreen(bookingId: widget.bookingData.id.validate())
            .launch(context);
      },
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }

  Future<void> _showGradientConfirmDialogItem({
    required BuildContext context,
    required String title,
    required VoidCallback onAccept,
    String? positiveText,
    String? negativeText,
  }) async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (_) {
        return Container(
          decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: boldTextStyle()),
              16.height,
              Row(
                children: [
                  AppButton(
                    text: negativeText ?? languages.lblNo,
                    elevation: 0,
                    color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                    textColor: textPrimaryColorGlobal,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  16.width,
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                    child: AppButton(
                      text: positiveText ?? languages.lblYes,
                      elevation: 0,
                      color: Colors.transparent,
                      textStyle: boldTextStyle(color: white),
                      onTap: () {
                        finish(context);
                        onAccept();
                      },
                    ),
                  ).expand(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
