import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/bid_price_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_request_details_screen.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import 'models/bidder_data.dart';
import 'models/post_job_data.dart';

class JobPostDetailScreen extends StatefulWidget {
  final PostJobData postJobData;

  JobPostDetailScreen({required this.postJobData});

  @override
  _JobPostDetailScreenState createState() => _JobPostDetailScreenState();
}

class _JobPostDetailScreenState extends State<JobPostDetailScreen> {
  late Future<PostJobDetailResponse> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getPostJobDetail(
        {PostJob.postRequestId: widget.postJobData.id.validate()});
  }

  Widget _buildSimpleRow({
    required String label,
    required String value,
    Color? valueBackgroundColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: boldTextStyle(size: 14),
          ),
          Expanded(
            child: valueBackgroundColor != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: valueBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textPrimaryColorGlobal,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: textPrimaryColorGlobal,
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 32, thickness: 1),
        Text(
          title,
          style: boldTextStyle(size: 16),
        ),
        12.height,
        ReadMoreText(
          parseHtmlString(content),
          style: primaryTextStyle(size: 14),
          colorClickableText: gradientBlue,
        ),
      ],
    );
  }

  String _formatPrice(num price, PriceType? priceType) {
    String formattedPrice = price.toPriceFormat();
    if (priceType == PriceType.hourly) {
      return '$formattedPrice/${languages.lblHr}';
    } else if (priceType == PriceType.daily) {
      return '$formattedPrice/${languages.lblDay}';
    } else if (priceType == PriceType.fixed) {
      return '$formattedPrice/${languages.lblFixed}';
    }
    return formattedPrice;
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    String location = "${data.cityName ?? ''}${data.countryName.validate().isEmpty ? "" : "${data.cityName.validate().isEmpty ? "" :  " - "}${data.countryName}"}";
    
    // Get travel_required value - convert to display string
    String travelRequiredValue = 'No'; // Default to "No"
    if (data.travelRequired != null) {
      travelRequiredValue = data.travelRequired!.displayName;
    } else {
      // If null, check if we can infer from other data or default to "No"
      travelRequiredValue = 'No';
    }
    
    // Debug: Log the travel_required value
    log('Travel Required - Raw: ${data.travelRequired}, Display: $travelRequiredValue');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Title
        Text(
          data.title.validate(),
          style: boldTextStyle(size: 18),
        ),
        8.height,
        
        // Location in red
        Text(
          location,
          style: boldTextStyle(size: 14, color: gradientRed),
        ),
        24.height,

        // Simple key-value pairs
        _buildSimpleRow(
          label: "Job Type",
          value: data.type?.displayName ?? '',
          valueBackgroundColor: data.type?.bgColor,
        ),
        _buildSimpleRow(
          label: languages.startDate,
          value: formatDate(data.startDate.validate()),
        ),
        _buildSimpleRow(
          label: languages.endDate,
          value: formatDate(data.endDate.validate()),
        ),
        _buildSimpleRow(
          label: "Budget/Price",
          value: _formatPrice(data.price.validate(), data.priceType),
        ),
        _buildSimpleRow(
          label: "Total Budget",
          value: data.totalBudget.validate().toPriceFormat(),
        ),
        _buildSimpleRow(
          label: "Total Days",
          value: data.totalDays?.toString() ?? '0',
        ),
        _buildSimpleRow(
          label: "Total Hours",
          value: data.totalHours?.toString() ?? '0',
        ),
        _buildSimpleRow(
          label: "Remote Work Level",
          value: data.remoteWorkLevel?.displayName ?? '',
        ),
        _buildSimpleRow(
          label: "Travel Required",
          value: travelRequiredValue,
        ),
        _buildSimpleRow(
          label: "Career Level",
          value: data.careerLevel?.displayName ?? '',
        ),
        _buildSimpleRow(
          label: "Education Level",
          value: data.educationLevel?.displayName ?? '',
        ),

        // Description, Requirements, Duties, Benefits - Simple sections
        if (data.description.validate().isNotEmpty) ...[
          _buildSimpleSection(
            title: languages.postJobDescription,
            content: data.description.validate(),
          ),
        ],
        if (data.requirement.validate().isNotEmpty) ...[
          _buildSimpleSection(
            title: "Skills & Requirements",
            content: data.requirement.validate(),
          ),
        ],
        if (data.duties.validate().isNotEmpty) ...[
          _buildSimpleSection(
            title: "Duties & Responsibilities",
            content: data.duties.validate(),
          ),
        ],
        if (data.benefits.validate().isNotEmpty) ...[
          _buildSimpleSection(
            title: "Benefits",
            content: data.benefits.validate(),
          ),
        ],
      ],
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    if (serviceList.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(languages.lblServices, style: boldTextStyle(size: LABEL_TEXT_SIZE))
            .paddingOnly(left: 16, right: 16),
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.imageAttachments.validate().isNotEmpty
                        ? data.imageAttachments!.first.validate()
                        : "",
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(),
                          style: primaryTextStyle(size: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                      .expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget providerWidget(List<BidderData> bidderList) {
    try {
      BidderData? myBid;
      if (bidderList.any((element) => element.providerId == appStore.userId)) {
        myBid = bidderList.firstWhere((element) => element.providerId == appStore.userId);
      }
      final otherBids = bidderList.where((element) => element.providerId != appStore.userId).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(myBid != null) ...[
            16.height,
            Text(languages.myBid, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            ProviderBidWidget(myBid),
          ],
          if(otherBids.isNotEmpty)...[
            Text(languages.bidList, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            AnimatedListView(
              itemCount: otherBids.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              itemBuilder: (_, i) {
                return ProviderBidWidget(otherBids[i]);
              },
            ),
          ]


        ],
      ).paddingOnly(left: 16, right: 16);
    } catch (e) {
      print(e);
    }

    return Offstage();
  }

  Widget ProviderBidWidget(BidderData bidderData) {
    if(bidderData.provider == null) return Offstage();
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          width: double.infinity,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImageWidget(
                    url: bidderData.provider!.profileImage.validate(),
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    circle: true,
                  ),
                  16.width,
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          bidderData.provider!.displayName.validate(),
                          style: boldTextStyle(size: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bidderData.provider!.designation.validate().isNotEmpty)
                        Marquee(
                          directionMarguee: DirectionMarguee.oneDirection,
                          child: Text(bidderData.provider!.designation.validate(),
                              style: primaryTextStyle(size: 14)),
                        ),
                      if(bidderData.provider!.cityName.validate().isNotEmpty || bidderData.provider!.countryName.validate().isNotEmpty) Text(
                        "${bidderData.provider!.cityName ?? ''}${bidderData.provider!.countryName.validate().isEmpty ? "" : "${bidderData.provider!.cityName.validate().isEmpty ? "" :  " - "}${bidderData.provider!.countryName}"}",
                        style: secondaryTextStyle(size: 12),
                      ),
                      DisabledRatingBarWidget(
                        rating: bidderData.provider!.providerServiceRating.validate(),
                        size: 14,
                      ),
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Row(
                          children: [
                            Text('Bid Price: ', style: secondaryTextStyle(size: 12)),
                            PriceWidget(
                              price: bidderData.price.validate(),
                              isHourlyService: bidderData.postJobData?.priceType == PriceType.hourly,
                              isDailyService: bidderData.postJobData?.priceType == PriceType.daily,
                              isFixesService: bidderData.postJobData?.priceType == PriceType.fixed,
                              hourlyTextColor: gradientBlue,
                              size: 14,
                            ),
                          ],
                        ),
                      ),

                    ],
                  ).expand(),
                ],
              ),
              4.height,
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                      child: AppButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'View Job',
                          style: boldTextStyle(color: white, size: 12),
                        ),
                        color: Colors.transparent,
                        elevation: 0,
                        onTap: () {
                          JobRequestDetailsScreen(
                            acceptedBidId: bidderData.id!,
                          ).launch(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                      child: AppButton(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          languages.whyChooseMe,
                          style: boldTextStyle(color: white, size: 12),
                        ),
                        color: Colors.transparent,
                        elevation: 0,
                        onTap: () {
                          showInDialog(
                            context,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages.whyChooseMe,
                                  style: primaryTextStyle(),
                                ),
                                GestureDetector(
                                  onTap: () => finish(context),
                                  child: Icon(
                                    Icons.close
                                  ),
                                )
                              ],
                            ),
                            builder: (context) => Text(
                               parseHtmlString(bidderData.whyChooseMe.validate()),
                              style: secondaryTextStyle(size: 12,color: textPrimaryColorGlobal),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        16.height,
      ],
    );
  }
  Widget customerWidget(PostJobData? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(
          languages.lblAboutCustomer,
          style: boldTextStyle(size: LABEL_TEXT_SIZE),
        ),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Row(
            children: [
              CachedImageWidget(
                url: data!.customerProfile.validate(),
                fit: BoxFit.cover,
                height: 60,
                width: 60,
                circle: true,
              ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          data.customerName.validate(),
                          style: boldTextStyle(size: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      4.height,
                      Text(
                        "${data.cityName ?? ''}${data.countryName.validate().isEmpty ? "" : "${data.cityName.validate().isEmpty ? "" :  " - "}${data.countryName}"}",
                        style: secondaryTextStyle(size: 12),
                      ),
                ],
              ).expand(),
            ],
          ),
        ),
        16.height,
      ],
    ).paddingOnly(left: 16, right: 16);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String image = '';

  jobImagesSection(PostJobData data) {
    final images = data.images;
    if (images.isEmpty) return Offstage();
    image = images.first;
    return StatefulBuilder(
      builder: (context,set) {
        return Column(
          children: [
            if (images.isNotEmpty)
              ClipRRect(
                borderRadius: radius(),
                child: Stack(
                  children: [
                    CachedImageWidget(
                      url: image,
                      fit: BoxFit.cover,
                      height: 250,
                      width: context.width(),
                      radius: 0,
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: radius(20),
                        ),
                        child: Text(
                          data.status.displayName,
                          style: boldTextStyle(color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: kAppPrimaryGradient,
                          borderRadius: radius(24),
                        ),
                        child: Row(
                          children: [
                            PriceWidget(
                              price: data.price.validate(),
                              isHourlyService: data.priceType == PriceType.hourly,
                              isDailyService: data.priceType == PriceType.daily,
                              isFixesService: data.priceType == PriceType.fixed,
                              color: Colors.white,
                              hourlyTextColor: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(left: 16, right: 16, top: 16),
            if (images.length > 1)
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      image = images[index];
                      set(() {});
                    },
                    child: CachedImageWidget(
                      url: images[index],
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                      radius: defaultRadius,
                    ),
                  ),
                  separatorBuilder: (context, index) => 16.width,
                  itemCount: images.length,
                ),
              ).paddingOnly(left: 16, right: 16, top: 16),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: '${widget.postJobData.title}',
      body: Stack(
        children: [
          SnapHelperWidget<PostJobDetailResponse>(
            future: future,
            initialData: cachedPostJobList.firstWhere((element) => element?.$1 == widget.postJobData.id.validate(), orElse: () => null)?.$2,
            onSuccess: (data) {
              return Stack(
                children: [
                  AnimatedScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    physics: AlwaysScrollableScrollPhysics(),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                    onSwipeRefresh: () async {

                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          jobImagesSection(data.postRequestDetail!),
                          postJobDetailWidget(data: data.postRequestDetail!).paddingSymmetric(horizontal: 16),
                          customerWidget(data.postRequestDetail!),
                          providerWidget(data.bidderData.validate()),
                          // postJobServiceWidget(serviceList: data.postRequestDetail!.service.validate()),
                          24.height,
                        ],
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      // Use the show_update_bid field from API response
                      // If false, hide the button (bid is cancelled)
                      // If true or null, show the button
                      if (data.showUpdateBid == false) {
                        return SizedBox.shrink();
                      }
                      
                      // Get user's bid for the dialog
                      BidderData? myBid;
                      if (data.bidderData.any((element) => element.providerId == appStore.userId)) {
                        myBid = data.bidderData.firstWhere((element) => element.providerId == appStore.userId);
                      }
                      
                      return Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: InkWell(
                      borderRadius: radius(14),
                      onTap: () async {
                        bool? res = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          hideSoftKeyboard: true,
                          backgroundColor: context.cardColor,
                          builder: (_) {
                            return BidPriceDialog(
                              data: widget.postJobData,
                              price: myBid?.price,
                              whyText: myBid?.whyChooseMe,
                              isUpdateBid: myBid != null,
                            );
                          }
                        );

                        if (res ?? false) {
                          init();
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: context.width(),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: kAppPrimaryGradient,
                          borderRadius: radius(14),
                        ),
                        child: Text(
                          data.postRequestDetail!.canBid.validate() ? languages.bid : "${languages.lblUpdate} ${languages.bid}",
                          style: boldTextStyle(color: white),
                        ),
                      ),
                    ),
                      );
                    },
                  ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
            loadingWidget: LoaderWidget(),
          ),
          Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading),
          )
        ],
      ),
    );
  }
}
