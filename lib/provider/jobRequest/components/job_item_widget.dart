import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/job_report_dialog.dart';
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
  final VoidCallback? onRefreshList;

  const JobItemWidget({
    required this.data,
    Key? key,
    this.onBidTap,
    this.onRefreshList,
  }) : super(key: key);

  @override
  State<JobItemWidget> createState() => _JobItemWidgetState();
}

class _JobItemWidgetState extends State<JobItemWidget> {
  Future<void> _openReportDialog() async {
    final id = widget.data.id?.toInt();
    if (id == null || id == 0) {
      toast(errorSomethingWentWrong);
      return;
    }
    await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      hideSoftKeyboard: true,
      builder: (_) => JobReportDialog(postJobId: id),
    );
  }

  void _confirmBlockCustomer() {
    final raw = widget.data.customerId;
    if (raw == null || raw.toInt() == 0) {
      toast(errorSomethingWentWrong);
      return;
    }
    final blockedUserId = raw.toInt();
    showConfirmDialogCustom(
      context,
      title: languages.lblBlockCustomerConfirmTitle,
      subTitle: languages.lblBlockCustomerConfirmMessage,
      primaryColor: context.primaryColor,
      positiveText: languages.lblBlock,
      negativeText: languages.lblCancel,
      onAccept: (ctx) async {
        try {
          final res = await blockPosterUser(blockedUserId: blockedUserId);
          toast(res.message.validate());
          widget.onRefreshList?.call();
        } catch (e) {
          toast(e.toString(), print: true);
        }
      },
    );
  }

  void _onMenuSelected(String value) {
    if (value == 'report') {
      _openReportDialog();
    } else if (value == 'block') {
      _confirmBlockCustomer();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                  width: double.infinity,
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
                      widget.data.status == RequestStatus.confirmDone ? languages.completed : widget.data.status.displayName,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      offset: Offset(0, 36),
                      color: context.cardColor,
                      icon: Icon(Icons.more_vert, color: Colors.white, size: 22),
                      onSelected: _onMenuSelected,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'report',
                          child: Text(
                            languages.lblReportJob,
                            style: primaryTextStyle(),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Text(
                            languages.lblBlockCustomer,
                            style: primaryTextStyle(),
                          ),
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
                // meta row: type, views, proposals (job type with distinct bg: onsite=green, hybrid=orange, remote=blue)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: boxDecorationDefault(
                        color: widget.data.type?.bgColor ?? context.scaffoldBackgroundColor,
                        borderRadius: radius(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.work_outline, size: 14, color: textSecondaryColorGlobal),
                          6.width,
                          Flexible(
                            child: Text(
                              widget.data.type?.displayName ?? '',
                              style: primaryTextStyle(size: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: textSecondaryColorGlobal),
                          6.width,
                          Flexible(
                            child: Text(
                              "${languages.views}: ${widget.data.totalViews ?? 0}",
                              style: secondaryTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 16, color: textSecondaryColorGlobal),
                          6.width,
                          Flexible(
                            child: Text(
                              "${languages.lblProposals}: ${widget.data.proposalsCount ?? 0}",
                              style: secondaryTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
