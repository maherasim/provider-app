import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_request_details_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../job_post_detail_screen.dart';
import '../models/post_job_data.dart';

class JobItemWidget extends StatefulWidget {
  final PostJobData data;
  final Function()? onBidTap;
  const JobItemWidget({required this.data, Key? key, this.onBidTap}) : super(key: key);

  @override
  State<JobItemWidget> createState() => _JobItemWidgetState();
}

class _JobItemWidgetState extends State<JobItemWidget> {
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      width: context.width(),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedImageWidget(
            url: widget.data.images.isNotEmpty ? widget.data.images.first : "",
            fit: BoxFit.cover,
            height: 60,
            width: 60,
            circle: false,
          ).cornerRadiusWithClipRRect(defaultRadius),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.data.title.validate(),
                    style: boldTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).expand(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.data.status.bgColor.withValues(alpha: .1),
                      borderRadius: radius(8),
                    ),
                    child: Text(
                      widget.data.status.displayName,
                      style: boldTextStyle(
                        color: widget.data.status.bgColor,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceWidget(
                    price: widget.data.price.validate(),
                    isHourlyService: widget.data.priceType == PriceType.hourly,
                    isDailyService: widget.data.priceType == PriceType.daily,
                    color: textPrimaryColorGlobal,
                    isFreeService: false,
                    size: 14,
                  ),
                  Text(
                    "Proposals: ${widget.data.proposalsCount ?? 0}",
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data.type?.displayName ?? '',
                    style: boldTextStyle(),
                  ),
                  Text(
                    "Views:${widget.data.totalViews ?? 0}",
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
              4.height,
              if(widget.data.cityName.validate().isNotEmpty || widget.data.countryName.validate().isNotEmpty) Text(
                "${widget.data.cityName ?? ''}${widget.data.countryName.validate().isEmpty ? "" : "${widget.data.cityName.validate().isEmpty ? "" :  " - "}${widget.data.countryName}"}",
                style: boldTextStyle(),
              ).paddingOnly(bottom: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      formatDate(widget.data.createdAt.validate()),
                      style: secondaryTextStyle(),
                    ),
                  ),
                ],
              ),

            ],
          ).expand(),
        ],
      ).onTap(() {
        if(widget.data.acceptedBidId != null && widget.data.providerId != null && widget.data.providerId == appStore.userId) {
          JobRequestDetailsScreen(
            acceptedBidId: widget.data.acceptedBidId!,
          ).launch(context);
        } else if(widget.data.status == RequestStatus.requested) {
          JobPostDetailScreen(postJobData: widget.data).launch(context);
        }
      }),
    );
  }
}
