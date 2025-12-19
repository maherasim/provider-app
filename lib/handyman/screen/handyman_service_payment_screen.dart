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
                padding: EdgeInsets.all(8),
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
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationRoundedWithShadow(16, backgroundColor: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.bookingId.validate(),
                style: boldTextStyle(size: 16),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: completed.withValues(alpha: 0.1),
                  borderRadius: radius(8),
                ),
                child: Text(
                  data.statusLabel.validate(),
                  style: boldTextStyle(size: 12, color: completed),
                ),
              ),
            ],
          ),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImageWidget(
                url: data.user?.profileImage.validate() ?? '',
                height: 50,
                width: 50,
                circle: true,
                fit: BoxFit.cover,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.servicePostJob.validate(),
                      style: boldTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.height,
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: context.iconColor),
                        4.width,
                        Expanded(
                          child: Text(
                            data.user?.name.validate() ?? '',
                            style: secondaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    if (data.user?.address.validate().isNotEmpty ?? false)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 16, color: context.iconColor),
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
                ),
              ),
            ],
          ),
          16.height,
          Divider(color: context.dividerColor, height: 1),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languages.paymentType, style: secondaryTextStyle(size: 12)),
                  4.height,
                  Text(
                    data.paymentType.validate().toUpperCase(),
                    style: boldTextStyle(),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(languages.myEarning, style: secondaryTextStyle(size: 12)),
                  4.height,
                  PriceWidget(
                    price: data.myEarning.validate(),
                    size: 18,
                    color: Colors.green,
                    isBoldText: true,
                  ),
                ],
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: context.iconColor),
              8.width,
              Expanded(
                child: Text(
                  data.datetime.validate(),
                  style: secondaryTextStyle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
