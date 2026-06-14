import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_service_payment_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

class HandymanServicePaymentScreen extends StatefulWidget {
  @override
  _HandymanServicePaymentScreenState createState() => _HandymanServicePaymentScreenState();
}

class _HandymanServicePaymentScreenState extends State<HandymanServicePaymentScreen> {
  List<HandymanServicePaymentModel> paymentList = [];
  Future<List<HandymanServicePaymentModel>>? future;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getHandymanServicePaymentList(
      page: page,
      payments: paymentList,
      callback: (res) {
        appStore.setLoading(false);
        isLastPage = res;
        setState(() {});
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.servicePayment,
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: kAppPrimaryGradient)),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<HandymanServicePaymentModel>>(
            future: future,
            loadingWidget: LoaderWidget(),
            onSuccess: (payments) {
              if (payments.isEmpty) {
                return NoDataWidget(
                  title: languages.lblNoEarningFound,
                  imageWidget: EmptyStateWidget(),
                );
              }

              return AnimatedListView(
                itemCount: paymentList.length,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8),
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  page = 1;
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    init();
                    setState(() {});
                  }
                },
                itemBuilder: (context, index) {
                  HandymanServicePaymentModel data = paymentList[index];
                  return _buildPaymentItem(data);
                },
                emptyWidget: NoDataWidget(
                  title: languages.lblNoEarningFound,
                  imageWidget: EmptyStateWidget(),
                ),
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);
                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(HandymanServicePaymentModel data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: boxDecorationRoundedWithShadow(
        16,
        backgroundColor: context.cardColor,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: kAppPrimaryGradient,
              borderRadius: radiusOnly(topLeft: 16, topRight: 16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: white, size: 20),
                    8.width,
                    Text(
                      data.bookingId.validate(),
                      style: boldTextStyle(size: 16, color: white),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.25),
                    borderRadius: radius(20),
                  ),
                  child: Text(
                    data.statusLabel.validate(),
                    style: boldTextStyle(size: 12, color: white),
                  ),
                ),
              ],
            ),
          ),
          
          // Service & Customer Info Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Row(
                  children: [
                    Icon(Icons.build_circle, size: 18, color: context.primaryColor),
                    8.width,
                    Expanded(
                      child: Text(
                        data.servicePostJob.validate(),
                        style: boldTextStyle(size: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                16.height,
                
                // Customer Info Card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: appStore.isDarkMode 
                        ? context.scaffoldBackgroundColor 
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: radius(12),
                  ),
                  child: Row(
                    children: [
                      CachedImageWidget(
                        url: data.user?.profileImage.validate() ?? '',
                        height: 56,
                        width: 56,
                        circle: true,
                        fit: BoxFit.cover,
                      ),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: context.iconColor),
                                4.width,
                                Expanded(
                                  child: Text(
                                    data.user?.name.validate() ?? '',
                                    style: boldTextStyle(size: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (data.user?.address.validate().isNotEmpty ?? false) ...[
                              6.height,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: context.iconColor),
                                  4.width,
                                  Expanded(
                                    child: Text(
                                      data.user?.address.validate() ?? '',
                                      style: secondaryTextStyle(size: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Payment Details Section with Highlight
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: Colors.green.withValues(alpha: 0.08),
              borderRadius: radius(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, size: 18, color: Colors.green.shade700),
                        8.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languages.paymentType,
                              style: secondaryTextStyle(size: 11),
                            ),
                            2.height,
                            Text(
                              data.paymentType.validate().toUpperCase(),
                              style: boldTextStyle(size: 13, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          languages.myEarning,
                          style: secondaryTextStyle(size: 11),
                        ),
                        2.height,
                        PriceWidget(
                          price: data.myEarning.validate(),
                          size: 20,
                          color: Colors.green.shade700,
                          isBoldText: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          16.height,
          
          // Date & Time Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: appStore.isDarkMode 
                    ? context.scaffoldBackgroundColor 
                    : Colors.blue.withValues(alpha: 0.05),
                borderRadius: radius(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: gradientBlue),
                  10.width,
                  Expanded(
                    child: Text(
                      data.datetime.validate(),
                      style: boldTextStyle(size: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Service Slots Section
          if (data.serviceSlots != null && data.serviceSlots!.isNotEmpty) ...[
            16.height,
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: appStore.isDarkMode 
                    ? context.scaffoldBackgroundColor 
                    : Colors.orange.withValues(alpha: 0.05),
                borderRadius: radius(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 18, color: gradientRed),
                      8.width,
                      Text(
                        'Service Slots',
                        style: boldTextStyle(size: 15),
                      ),
                      if (data.serviceSlots != null) ...[
                        8.width,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradientRed.withValues(alpha: 0.15),
                            borderRadius: radius(12),
                          ),
                          child: Text(
                            '${data.serviceSlots!.length}',
                            style: boldTextStyle(size: 12, color: gradientRed),
                          ),
                        ),
                      ],
                    ],
                  ),
                  12.height,
                  ...data.serviceSlots!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final slot = entry.value;
                    String dateStr = slot.date.validate();
                    String startTime = slot.startTime.validate();
                    String endTime = slot.endTime.validate();
                    String formattedDate = '';
                    String formattedStartTime = '';
                    String formattedEndTime = '';
                    
                    try {
                      if (dateStr.isNotEmpty) {
                        formattedDate = formatDate(dateStr, format: DATE_FORMAT_2);
                      }
                      if (startTime.isNotEmpty) {
                        List<String> timeParts = startTime.split(':');
                        if (timeParts.length >= 2) {
                          formattedStartTime = '${timeParts[0]}:${timeParts[1]}';
                        } else {
                          formattedStartTime = startTime;
                        }
                      }
                      if (endTime.isNotEmpty) {
                        List<String> timeParts = endTime.split(':');
                        if (timeParts.length >= 2) {
                          formattedEndTime = '${timeParts[0]}:${timeParts[1]}';
                        } else {
                          formattedEndTime = endTime;
                        }
                      }
                    } catch (e) {
                      formattedDate = dateStr;
                      formattedStartTime = startTime;
                      formattedEndTime = endTime;
                    }
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: index < data.serviceSlots!.length - 1 ? 10 : 0),
                      padding: EdgeInsets.all(12),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: radius(10),
                        border: Border.all(
                          color: context.dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: gradientBlue.withValues(alpha: 0.1),
                              borderRadius: radius(8),
                            ),
                            child: Icon(
                              Icons.event,
                              size: 18,
                              color: gradientBlue,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (formattedDate.isNotEmpty)
                                  Text(
                                    formattedDate,
                                    style: boldTextStyle(size: 13),
                                  ),
                                if (formattedStartTime.isNotEmpty && formattedEndTime.isNotEmpty) ...[
                                  6.height,
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, size: 14, color: context.iconColor),
                                      6.width,
                                      Text(
                                        '$formattedStartTime - $formattedEndTime',
                                        style: secondaryTextStyle(size: 12),
                                      ),
                                      if (slot.totalHours != null && slot.totalHours! > 0) ...[
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: gradientBlue.withValues(alpha: 0.1),
                                            borderRadius: radius(6),
                                          ),
                                          child: Text(
                                            '${slot.totalHours}h',
                                            style: boldTextStyle(size: 11, color: gradientBlue),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          16.height,
        ],
      ),
    );
  }
}
