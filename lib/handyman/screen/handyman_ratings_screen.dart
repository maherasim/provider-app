import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_rating_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

class HandymanRatingsScreen extends StatefulWidget {
  @override
  _HandymanRatingsScreenState createState() => _HandymanRatingsScreenState();
}

class _HandymanRatingsScreenState extends State<HandymanRatingsScreen> {
  List<HandymanRatingModel> ratingList = [];
  Future<List<HandymanRatingModel>>? future;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getHandymanRatingsList(
      page: page,
      ratings: ratingList,
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

  Widget _buildStarRating(num rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          color: index < rating.round() ? Colors.green : Colors.grey,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.handymanRatings,
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: kAppPrimaryGradient)),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<HandymanRatingModel>>(
            future: future,
            loadingWidget: LoaderWidget(),
            onSuccess: (ratings) {
              if (ratings.isEmpty) {
                return NoDataWidget(
                  title: languages.lblNoReviewYet,
                  imageWidget: EmptyStateWidget(),
                );
              }

              return AnimatedListView(
                itemCount: ratingList.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
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
                  HandymanRatingModel data = ratingList[index];
                  return _buildRatingCard(data);
                },
                emptyWidget: NoDataWidget(
                  title: languages.lblNoReviewYet,
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

  Widget _buildRatingCard(HandymanRatingModel data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationRoundedWithShadow(16, backgroundColor: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer and Service Information Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Profile Image
              CachedImageWidget(
                url: data.customer?.profileImage.validate() ?? '',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                circle: true,
              ),
              12.width,
              // Customer Name and Service Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.customer?.name.validate() ?? '',
                      style: boldTextStyle(size: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      data.service?.name.validate() ?? '',
                      style: secondaryTextStyle(size: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.customer?.address.validate().isNotEmpty ?? false) ...[
                      4.height,
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: context.iconColor),
                          4.width,
                          Expanded(
                            child: Text(
                              data.customer?.address.validate() ?? '',
                              style: secondaryTextStyle(size: 12),
                              maxLines: 1,
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
          // Divider
          Divider(color: context.dividerColor, height: 20, thickness: 1),
          // Rating and Review Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Star Rating
              _buildStarRating(data.rating.validate()),
              8.width,
              // Booking ID
              Text(
                '#${data.bookingId.validate()}',
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
          12.height,
          // Review Text
          if (data.review.validate().isNotEmpty)
            Text(
              data.review.validate(),
              style: primaryTextStyle(),
            ),
          // Date
          if (data.createdAt.validate().isNotEmpty) ...[
            12.height,
            Text(
              formatDate(data.createdAt.validate(), format: DATE_FORMAT_4),
              style: secondaryTextStyle(size: 12),
            ),
          ],
        ],
      ),
    );
  }
}
