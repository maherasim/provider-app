import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_request_details_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../utils/colors.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status and price pill overlays
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                CachedImageWidget(
                  url: widget.data.images.isNotEmpty ? widget.data.images.first : "",
                  fit: BoxFit.cover,
                  height: 170,
                  width: context.width(),
                  circle: false,
                ),
                // Status chip
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: radius(20),
                    ),
                    child: Text(
                      widget.data.status.displayName,
                      style: boldTextStyle(color: Colors.white, size: 12),
                    ),
                  ),
                ),
                // Price gradient pill
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: kAppPrimaryGradient,
                      borderRadius: radius(24),
                    ),
                    child: Row(
                      children: [
                        PriceWidget(
                          price: widget.data.price.validate(),
                          isHourlyService: widget.data.priceType == PriceType.hourly,
                          isDailyService: widget.data.priceType == PriceType.daily,
                          color: Colors.white,
                          hourlyTextColor: Colors.white,
                          isFreeService: false,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.title.validate(),
                  style: boldTextStyle(size: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                6.height,
                // location
                if (widget.data.cityName.validate().isNotEmpty || widget.data.countryName.validate().isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textSecondaryColorGlobal),
                      6.width,
                      Expanded(
                        child: Text(
                          "${widget.data.cityName ?? ''}${widget.data.countryName.validate().isEmpty ? "" : "${widget.data.cityName.validate().isEmpty ? "" : " - "}${widget.data.countryName}"}",
                          style: secondaryTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                10.height,
                // meta row: type, views, proposals
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor, borderRadius: radius(20)),
                      child: Row(
                        children: [
                          Icon(Icons.work_outline, size: 14, color: textSecondaryColorGlobal),
                          6.width,
                          Text(widget.data.type?.displayName ?? '', style: primaryTextStyle(size: 12)),
                        ],
                      ),
                    ),
                    10.width,
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16, color: textSecondaryColorGlobal),
                        6.width,
                        Text("Views: ${widget.data.totalViews ?? 0}", style: secondaryTextStyle()),
                      ],
                    ).expand(),
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 16, color: textSecondaryColorGlobal),
                        6.width,
                        Text("Proposals: ${widget.data.proposalsCount ?? 0}", style: secondaryTextStyle()),
                      ],
                    ),
                  ],
                ),
                10.height,
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: textSecondaryColorGlobal),
                    6.width,
                    Text(formatDate(widget.data.createdAt.validate()), style: secondaryTextStyle()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
        if(widget.data.acceptedBidId != null && widget.data.providerId != null && widget.data.providerId == appStore.userId) {
          JobRequestDetailsScreen(
            acceptedBidId: widget.data.acceptedBidId!,
          ).launch(context);
        } else {
          JobPostDetailScreen(postJobData: widget.data).launch(context);
        }
      });
  }
}
