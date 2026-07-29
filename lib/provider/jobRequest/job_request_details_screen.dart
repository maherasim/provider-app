
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/components/profile_report_dialog.dart';
import 'package:handyman_provider_flutter/components/review_report_dialog.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/extra_charges_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/job_report_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/hold_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/post_job_bid_rating_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/split_payment.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/networks/frobster_chat_api.dart';
import 'package:handyman_provider_flutter/screens/chat/frobster_chat_thread_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

Widget _gradientButton(BuildContext context, String text, VoidCallback onTap) {
  return InkWell(
    borderRadius: radius(12),
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(12)),
      child: Text(text, style: boldTextStyle(color: white, size: 16)),
    ),
  );
}

class JobRequestDetailsScreen extends StatefulWidget {
  final num acceptedBidId;
  final VoidCallback? callback;

  const JobRequestDetailsScreen({
    Key? key,
    required this.acceptedBidId,
    this.callback
  }) : super(key: key);

  @override
  State<JobRequestDetailsScreen> createState() => _JobRequestDetailsScreenState();
}

class _JobRequestDetailsScreenState extends State<JobRequestDetailsScreen> {
  /// Customer-authored review on post-job bid (`post_job_bid_customer_ratings`).
  static const String _ugcReviewTypePostJobBidCustomerRating =
      'post_job_bid_customer_rating';

  Future<JobRequestDetailResponse?>? future;
  JobRequestDetailResponse? postJobDetail;

  Future<void> _openProfileReportDialog(int reportedUserId) async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      hideSoftKeyboard: true,
      builder: (_) => ProfileReportDialog(reportedUserId: reportedUserId),
    );
  }

  Future<void> _openReviewReportDialog({
    required int reviewId,
    required String reviewType,
  }) async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      hideSoftKeyboard: true,
      builder: (_) =>
          ReviewReportDialog(reviewId: reviewId, reviewType: reviewType),
    );
  }

  Future<void> _openJobPostReportDialog(int postJobId) async {
    if (postJobId == 0) {
      toast(errorSomethingWentWrong);
      return;
    }
    await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      hideSoftKeyboard: true,
      builder: (_) => JobReportDialog(postJobId: postJobId),
    );
  }

  /// Post job listing id for `/api/ugc/report-post-job` (not the bid id).
  int _intPostJobIdForUgcReport() {
    final d = postJobDetail;
    if (d == null) return 0;
    final nested = d.postRequest?.id;
    if (nested != null && nested > 0) return nested;
    final top = d.postRequestId;
    if (top != null && top > 0) return top;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getPostJobDetailByBid(widget.acceptedBidId);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.lblBidDetails,
      body: SnapHelperWidget<JobRequestDetailResponse?>(
        future: future,
        onSuccess: (data) {
          postJobDetail = data;
          return _buildBody();
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
    );
  }

  String getStatusInfo(JobRequestDetailResponse job) {
    String message = '';
    switch(job.status) {
      case RequestStatus.requested:
        message = languages.waitingForCustomerToAcceptTheBid;
        break;
      case RequestStatus.accepted:
        message = languages.waitingForProviderToSplitPayment;
        break;
      case RequestStatus.pendingAdvance:
        message = languages.waitingForCustomerToPayAdvancePercentage;
        break;
      case RequestStatus.advancePaid:
        message = languages.waitingForProviderToStartWork;
        break;
      case RequestStatus.inProcess:
        message = languages.waitingForCustomerToConfirm;
        break;
      case RequestStatus.inProgress:
        message = languages.workInProgressWaitingForProvider;
        break;
      case RequestStatus.hold:
        message = languages.waitingForProviderToResumeWork;
        break;
      case RequestStatus.done:
        message = languages.waitingForCustomerToConfirmWorkDone;
        break;
      case RequestStatus.confirmDone:
        message = languages.waitingForProviderToMarkBidAsCompleted;
        break;
      case RequestStatus.completed:
        message = languages.jobCompletedWaitingForCustomer;
        break;
      case RequestStatus.remainingPaymentPending:
        message = languages.lblWaitingForAdminApproval;
        break;
      case RequestStatus.remainingPaid:
        message = languages.paymentCompletedDownloadInvoice;
        break;
      case RequestStatus.cancel:
        message = languages.lblThisBidWasCancelled;
        break;
      case RequestStatus.pending:
        message = languages.statusPending;
        break;
      case RequestStatus.assigned:
        message = languages.statusAssigned;
        break;
    }

    return message;
  }

  static const _statusesShowingWorkingAddress = [
    RequestStatus.advancePaid,
    RequestStatus.inProgress,
    RequestStatus.inProcess,
    RequestStatus.hold,
    RequestStatus.done,
    RequestStatus.completed,
    RequestStatus.remainingPaymentPending,
    RequestStatus.remainingPaid,
  ];

  bool _shouldShowWorkingAddress(JobRequestDetailResponse detail) {
    return _statusesShowingWorkingAddress.contains(detail.status);
  }

  String _workingAddressDisplay(JobRequestDetailResponse detail) {
    final raw = detail.postRequest?.workingAddress?.toString().trim() ?? '';
    if (raw.isEmpty || raw == 'null') return '';
    return raw;
  }

  Widget _buildBody() {
    if (postJobDetail == null) return SizedBox.shrink();

    int currentStep() {
      final s = postJobDetail!.status;
      if (s == RequestStatus.requested) return 0;
      if (s == RequestStatus.accepted) return 1;
      if (s == RequestStatus.pendingAdvance) return 2;
      if (s == RequestStatus.advancePaid) return 3;
      if (s == RequestStatus.inProcess) return 4;
      if (s == RequestStatus.inProgress || s == RequestStatus.hold || s == RequestStatus.done || s == RequestStatus.confirmDone || s == RequestStatus.remainingPaymentPending) return 5;
      if (s == RequestStatus.completed || s == RequestStatus.remainingPaid) return 6;
      return 0;
    }

    Widget _stepBar(int index, int activeTill) {
      final bool active = index <= activeTill;
      return Expanded(
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: active ? gradientBlue : gradientBlue.withValues(alpha: 0.15),
                borderRadius: radius(6),
              ),
            ),
            6.height,
          ],
        ),
      );
    }

    Widget _progressSteps() {
      final activeTill = currentStep();
      final labels = [languages.accept, languages.lblProgressAdvance, languages.lblProgressAdvancePaidShort, languages.lblProgressLetsStart, languages.lblProgressWork];
      return Column(
        children: [
          Row(
            children: [
              _stepBar(1, activeTill),
              8.width,
              _stepBar(2, activeTill),
              8.width,
              _stepBar(3, activeTill),
              8.width,
              _stepBar(4, activeTill),
              8.width,
              _stepBar(5, activeTill),
            ],
          ),
          Row(
            children: [
              for (int i = 0; i < labels.length; i++) ...[
                if (i > 0) 8.width,
                Expanded(
                  child: Text(labels[i], style: secondaryTextStyle(size: 12), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ),
              ],
            ],
          ),
        ],
      );
    }

    Widget _bidderSummary() {
      final providerName = postJobDetail?.provider?.displayName.validate() ?? '';
      final advancePct = (postJobDetail?.advancePercent ?? 0).toString();
      return Container(
        padding: EdgeInsets.all(10),
        decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius(12)),
        child: Row(
          children: [
            // Simple initials circle
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: gradientBlue.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Text(
                providerName.isNotEmpty ? providerName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase() : 'BG',
                style: boldTextStyle(color: gradientBlue, size: 12),
              ),
            ),
            10.width,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(providerName, style: boldTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  4.height,
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${languages.bid}:', style: secondaryTextStyle(size: 12)),
                      PriceWidget(price: postJobDetail?.price ?? 0, color: textPrimaryColorGlobal, size: 14),
                      Text('• ${languages.advancePercentage} $advancePct%', style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                ],
              ),
            ),
            8.width,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: postJobDetail!.status.bgColor.withValues(alpha: 0.1), borderRadius: radius(20)),
              child: Text(postJobDetail!.status.displayName, style: boldTextStyle(color: postJobDetail!.status.bgColor, size: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: AnimatedScrollView(
            padding: EdgeInsets.only(bottom: 60 + MediaQuery.of(context).padding.bottom, top: 16, right: 16, left: 16),
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            onSwipeRefresh: () async {
              init();
              setState(() {});

              return await 2.seconds.delay;
            },
            children: [
              // Status Info Card
              if(getStatusInfo(postJobDetail!).isNotEmpty) Container(
                padding: EdgeInsets.all(10),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: gradientBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: gradientBlue, size: 18),
                    8.width,
                    Expanded(
                      child: Text(
                        getStatusInfo(postJobDetail!),
                        style: secondaryTextStyle(color: gradientBlue, size: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              24.height,
              // Bidder summary (name, bid amount, advance %, status chip)
              _bidderSummary(),
              16.height,
              // Step progress row with labels
              _progressSteps(),
              24.height,

              // Job Details Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // Slightly taller cells so Title / 2-line values + flag fit (avoids ~6px bottom overflow).
                childAspectRatio: 1.92,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildInfoCard(
                    icon: Icons.h_mobiledata,
                    iconColor: gradientBlue,
                    title: languages.lblTitle,
                    value: postJobDetail!.postRequest?.title?.validate() ??
                        postJobDetail!.title?.validate() ??
                        '',
                    postJobIdToReport: _intPostJobIdForUgcReport(),
                  ),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    title: languages.location,
                    value: "${postJobDetail!.postRequest?.city?.name}${(postJobDetail!.postRequest?.country?.name??'').isEmpty ? '' : ', ${postJobDetail!.postRequest?.country?.name}' }",
                  ),
                  _buildInfoCard(
                    icon: Icons.business_center,
                    iconColor: Colors.orange,
                    title: languages.lblJobType,
                    value: postJobDetail!.postRequest?.type.displayName.validate() ?? '',
                    cardBackgroundColor: postJobDetail!.postRequest?.type.bgColor,
                  ),
                  _buildInfoCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.green[600]!,
                    title: languages.lblRateType,
                    value: switch (postJobDetail!.postRequest?.priceType) {
                      PriceType.hourly => languages.lblHourly,
                      PriceType.fixed => languages.lblFixed,
                      PriceType.daily => languages.lblDaily,
                      null => '',
                    },
                  ),
                  _buildInfoCard(
                    icon: Icons.event_available,
                    iconColor: Colors.blue,
                    title: languages.lblStartDate,
                    value: formatDate(postJobDetail!.postRequest?.startDate?.toIso8601String().validate(),showDateWithTime: true),
                    isDate: true,
                  ),
                  _buildInfoCard(
                    icon: Icons.event_busy,
                    iconColor: Colors.red,
                    title: languages.lblEndDate,
                    value:  formatDate(postJobDetail!.postRequest?.endDate?.toIso8601String().validate(),showDateWithTime: true),
                    isDate: true,
                  ),
                  _buildInfoCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue,
                    title: languages.lblTotalBudget,
                    value: postJobDetail!.postRequest?.totalBudget?.validate().toPriceFormat() ?? '0',
                  ),
                  _buildInfoCard(
                    icon: Icons.groups,
                    iconColor: Colors.grey,
                    title: languages.lblProposals,
                    value: (postJobDetail!.postRequest?.postBidList.length??0).validate().toString(), // Simplified for now
                  ),
                  _buildInfoCard(
                    icon: Icons.person,
                    iconColor: Colors.indigo,
                    title: languages.lblWorker,
                    value: postJobDetail!.provider?.displayName.validate() ?? '',
                    profileUserIdToReport: postJobDetail!.provider?.id,
                  ),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    iconColor: Colors.green,
                    title: languages.lblAboutCustomer,
                    value:  postJobDetail!.customer?.displayName.validate() ?? '',
                    profileUserIdToReport: postJobDetail!.customer?.id,
                  ),
                ],
              ),
              16.height,

              // Working Address card – only for statuses where job is active/completed
              if (_shouldShowWorkingAddress(postJobDetail!) && _workingAddressDisplay(postJobDetail!).isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.work_outline, color: Colors.brown, size: 22),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(languages.workingAddress, style: secondaryTextStyle(size: 11)),
                              4.height,
                              Text(
                                _workingAddressDisplay(postJobDetail!),
                                style: primaryTextStyle(size: 14),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Status Card - Full Width
              Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: gradientBlue, size: 24),
                    6.height,
                    Text(
                      languages.lblStatus,
                      style: secondaryTextStyle(size: 11),
                    ),
                    4.height,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: postJobDetail!.status.bgColor.withValues(alpha: 0.1),
                        borderRadius: radius(8),
                      ),
                      child: Text(
                        postJobDetail!.status.displayName,
                        style: boldTextStyle(
                          color: postJobDetail!.status.bgColor,
                          size: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Price Breakdown Card
              _buildPriceBreakdown(postJobDetail!),

              // Extra Charges Breakdown
              _buildExtraChargesBreakdown(),

              // Employer Review (reviews from customer about provider)
              _buildReviewSection(
                languages.lblEmployerReview,
                postJobDetail!.providerReview,
                reviewReportType: _ugcReviewTypePostJobBidCustomerRating,
                showReportOnReviews:
                    appStore.userId == postJobDetail?.providerId,
              ),

              // Customer Review (reviews from provider about customer / employer)
              _buildReviewSection(languages.lblCustomerReview, postJobDetail!.customerReview),

              24.height,

            ],
          ),
        ),
        if(appStore.userId == postJobDetail?.providerId) Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if(postJobDetail!.status == RequestStatus.accepted) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, languages.lblSplitPayment, () async {
                        bool? res = await showInDialog(
                            context,
                            contentPadding: EdgeInsets.zero,
                            hideSoftKeyboard: true,
                            backgroundColor: context.cardColor,
                            builder: (_) => SplitPaymentDialog(data: postJobDetail!)
                        );

                        if (res ?? false) {
                          init();
                          setState(() {});
                        }
                      }),
                  ),
                  16.width,
                  Expanded(
                    child: _gradientButton(context, languages.lblCancel, () async {
                        confirmationRequestDialog(context,RequestStatus.cancel);
                    }),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.inProgress) Column(
                children: [
                  Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: languages.hold,
                      textStyle: boldTextStyle(color: white, size: 16),
                      color: hold,
                      width: context.width(),
                      onTap: () async {
                        bool? res = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          hideSoftKeyboard: true,
                          backgroundColor: context.cardColor,
                          builder: (_) =>  HoldReasonDialog(data: postJobDetail!),
                        );
                        if (res ?? false) {
                          init();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: _gradientButton(context, languages.done, () async {
                      confirmationRequestDialog(context, RequestStatus.done);
                    }),
                  ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Expanded(
                        child: _gradientButton(context, languages.lblChat, () async {
                            final customerId = postJobDetail?.customer?.id;
                            if (customerId == null) {
                              toast(languages.somethingWentWrong);
                              return;
                            }
                            toast(languages.pleaseWaitWhileWeLoadChatDetails);
                            try {
                              final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                              Fluttertoast.cancel();
                              if (res.status && res.conversationId != 0) {
                                FrobsterChatThreadScreen(
                                  conversationId: res.conversationId,
                                  title: languages.lblDirectMessage,
                                  otherDisplayName: postJobDetail?.customer?.displayName,
                                ).launch(context);
                              } else {
                                toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                              }
                            } catch (e) {
                              Fluttertoast.cancel();
                              toast(e.toString(), print: true);
                            }
                          }),
                      ),
                    ],
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.hold) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, languages.resumeWork, () async {
                  confirmationRequestDialog(context, RequestStatus.inProgress);
                    }),
                  ),
                  16.width,
                  Expanded(
                    child: _gradientButton(context, languages.lblChat, () async {
                        final customerId = postJobDetail?.customer?.id;
                        if (customerId == null) {
                          toast(languages.somethingWentWrong);
                          return;
                        }
                        toast(languages.pleaseWaitWhileWeLoadChatDetails);
                        try {
                          final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                          Fluttertoast.cancel();
                          if (res.status && res.conversationId != 0) {
                            FrobsterChatThreadScreen(
                              conversationId: res.conversationId,
                              title: languages.lblDirectMessage,
                              otherDisplayName: postJobDetail?.customer?.displayName,
                            ).launch(context);
                          } else {
                            toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                          }
                        } catch (e) {
                          Fluttertoast.cancel();
                          toast(e.toString(), print: true);
                        }
                      }),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.confirmDone) Column(
                children: [
                  Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, languages.lblMarkComplete, () async {
                      confirmationRequestDialog(context, RequestStatus.completed);
                    }),
                  ),
                  16.width,
                  Expanded(
                        child: _gradientButton(context, '+ ${languages.lblExtraCharges}', () async {
                        bool? res = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          hideSoftKeyboard: true,
                          backgroundColor: context.cardColor,
                          builder: (_) =>  ExtraChargesDialog(data: postJobDetail!),
                        );
                        if (res ?? false) {
                          init();
                          setState(() {});
                        }
                        }),
                    ),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Expanded(
                        child: _gradientButton(context, languages.lblChat, () async {
                            final customerId = postJobDetail?.customer?.id;
                            if (customerId == null) {
                              toast(languages.somethingWentWrong);
                              return;
                            }
                            toast(languages.pleaseWaitWhileWeLoadChatDetails);
                            try {
                              final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                              Fluttertoast.cancel();
                              if (res.status && res.conversationId != 0) {
                                FrobsterChatThreadScreen(
                                  conversationId: res.conversationId,
                                  title: languages.lblDirectMessage,
                                  otherDisplayName: postJobDetail?.customer?.displayName,
                                ).launch(context);
                              } else {
                                toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                              }
                            } catch (e) {
                              Fluttertoast.cancel();
                              toast(e.toString(), print: true);
                            }
                          }),
                      ),
                    ],
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.advancePaid) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, languages.lblStartWork, () async {
                      confirmationRequestDialog(context, RequestStatus.inProcess);
                    }),
                  ),
                  16.width,
                  Expanded(
                    child: _gradientButton(context, languages.lblChat, () async {
                        final customerId = postJobDetail?.customer?.id;
                        if (customerId == null) {
                          toast(languages.somethingWentWrong);
                          return;
                        }
                        toast(languages.pleaseWaitWhileWeLoadChatDetails);
                        try {
                          final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                          Fluttertoast.cancel();
                          if (res.status && res.conversationId != 0) {
                            FrobsterChatThreadScreen(
                              conversationId: res.conversationId,
                              title: languages.lblDirectMessage,
                              otherDisplayName: postJobDetail?.customer?.displayName,
                            ).launch(context);
                          } else {
                            toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                          }
                        } catch (e) {
                          Fluttertoast.cancel();
                          toast(e.toString(), print: true);
                        }
                      }),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if([RequestStatus.inProcess, RequestStatus.done, RequestStatus.completed].contains(postJobDetail!.status)) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, languages.lblChat, () async {
                        final customerId = postJobDetail?.customer?.id;
                        if (customerId == null) {
                          toast(languages.somethingWentWrong);
                          return;
                        }
                        toast(languages.pleaseWaitWhileWeLoadChatDetails);
                        try {
                          final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                          Fluttertoast.cancel();
                          if (res.status && res.conversationId != 0) {
                            FrobsterChatThreadScreen(
                              conversationId: res.conversationId,
                              title: languages.lblDirectMessage,
                              otherDisplayName: postJobDetail?.customer?.displayName,
                            ).launch(context);
                          } else {
                            toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                          }
                        } catch (e) {
                          Fluttertoast.cancel();
                          toast(e.toString(), print: true);
                        }
                      }),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.remainingPaid) Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _gradientButton(context, languages.lblChat, () async {
                            final customerId = postJobDetail?.customer?.id;
                            if (customerId == null) {
                              toast(languages.somethingWentWrong);
                              return;
                            }
                            toast(languages.pleaseWaitWhileWeLoadChatDetails);
                            try {
                              final res = await FrobsterChatApi.openWithUser(userId: customerId, title: languages.lblDirectMessage);
                              Fluttertoast.cancel();
                              if (res.status && res.conversationId != 0) {
                                FrobsterChatThreadScreen(
                                  conversationId: res.conversationId,
                                  title: languages.lblDirectMessage,
                                  otherDisplayName: postJobDetail?.customer?.displayName,
                                ).launch(context);
                              } else {
                                toast("${postJobDetail?.customer?.displayName} ${languages.isNotAvailableForChat}");
                              }
                            } catch (e) {
                              Fluttertoast.cancel();
                              toast(e.toString(), print: true);
                            }
                          }),
                      ),
                      16.width,
                      Expanded(
                        child: _gradientButton(context, languages.lblDownload, () async {
                        if(postJobDetail!.id == null) {
                          toast(languages.somethingWentWrong);
                          return;
                        }
                        appStore.setLoading(true);
                        downloadBidInvoice(postJobDetail!.id!).then((value) {
                          appStore.setLoading(false);
                          toast(value.message.validate());
                        }).catchError((e) {
                          appStore.setLoading(false);
                          toast(e.toString());
                        });
                        }),
                    ),
                    ],
                  ),
                  if(postJobDetail!.showRateCustomerButton == true) ...[
                    16.height,
                    Row(
                      children: [
                        Expanded(
                          child: _gradientButton(context, languages.rateCustomer, () async {
                            if (postJobDetail?.id == null || postJobDetail?.providerId == null || postJobDetail?.customer?.id == null) {
                              toast(languages.somethingWentWrong);
                              return;
                            }
                            bool? res = await showInDialog(
                              context,
                              contentPadding: EdgeInsets.zero,
                              hideSoftKeyboard: true,
                              backgroundColor: context.cardColor,
                              builder: (_) => PostJobBidRatingDialog(
                                postJobBidId: postJobDetail!.id!,
                                providerId: postJobDetail!.providerId!,
                                customerId: postJobDetail!.customer!.id!,
                                customerName: postJobDetail?.customer?.displayName,
                                customerImage: null,
                                customerCity: null,
                                customerCountry: null,
                                customerRating: null,
                                customerTotalRatings: null,
                              ),
                            );
                            if (res ?? false) {
                              init();
                              setState(() {});
                            }
                          }),
                        ),
                      ],
                    ),
                  ],
                ],
              ).paddingOnly(bottom: 24 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> confirmationRequestDialog(BuildContext context, RequestStatus status) async {

    showConfirmDialogCustom(
      context,
      title: languages.confirmationRequestTxt,
      primaryColor: status == BookingStatusKeys.rejected ? Colors.redAccent : primaryColor,
      positiveText: languages.lblYes,
      negativeText: languages.lblNo,
      onAccept: (context) async {
        appStore.setLoading(true);
        final request = {
          "status": status.backendValue
        };

        await bidUpdate(postJobDetail!.id.validate(),request).then((res) async {
          init();
          setState(() {});
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      },
    );
  }

  int getQuantityByPriceType(PostRequest post) {
    if(post.priceType == PriceType.fixed){
      return 1;
    } else if(post.priceType == PriceType.hourly) {
      return post.totalHours ?? 1;
    } else {
      return post.totalDays ?? 1;
    }
  }


  num quantity = 1;
  num  totalAmount = 0;
  num extraCharges = 0;
  num subTotal = 0;
  num tax = 0;
  num netAmount = 0;
  num advance = 0;
  num remaining = 0;
  Widget _buildPriceBreakdown(JobRequestDetailResponse data) {
    quantity = getQuantityByPriceType(postJobDetail!.postRequest!);
    totalAmount = (postJobDetail!.price ?? 0) * quantity;
    extraCharges = postJobDetail!.extraCharges.fold(0, (sum,ec) => sum + ((ec.amount ?? 0) * (ec.quantity ?? 0)));
    subTotal = totalAmount + extraCharges;
    double taxPercent = 0.0;
    if((postJobDetail!.taxPercent??'0%').split("%").length >= 2) {
      String  taxPe = (postJobDetail!.taxPercent??'0%').split("%").first.validate();
      taxPercent = double.tryParse(taxPe) ?? 0;
    }
    print(taxPercent);
    print("taxPercent");
    tax = subTotal * (taxPercent/100);
    netAmount = subTotal - tax;
    advance = (totalAmount * ((postJobDetail?.advancePercent ?? 0) / 100));
    remaining = subTotal - advance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(languages.lblPriceDetail, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          padding: EdgeInsets.all(12),
          width: context.width(),
          decoration: boxDecorationDefault(color: context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(languages.lblRateUnitPrice, style: secondaryTextStyle(size: 12)).expand(),
                  16.width,
                  PriceWidget(
                    price: data.price?.validate() ?? 0,
                    color: textPrimaryColorGlobal,
                    isBoldText: true,
                    size: 14,
                  ),
                ],
              ),
              16.height,

              // Quantity row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(languages.lblQuantity, style: secondaryTextStyle(size: 12)).flexible(fit: FlexFit.loose),
                  16.width,
                  Text(quantity.toString(), style: boldTextStyle(size: 14)),
                ],
              ),
              16.height,

              // Total calculation row
              Row(
                children: [
                  Text(languages.lblTotal, style: secondaryTextStyle(size: 12)).expand(),
                  16.width,
                  PriceWidget(
                    price: totalAmount,
                    color: textPrimaryColorGlobal,
                    size: 14,
                  ),
                ],
              ),
              16.height,

              // Extra Charges Total
              if (extraCharges > 0)
                Row(
                  children: [
                    Text(languages.lblExtraCharges, style: secondaryTextStyle(size: 12)).expand(),
                    16.width,
                    PriceWidget(
                      price: extraCharges,
                      color: textPrimaryColorGlobal,
                      size: 14,
                    ),
                  ],
                ),
              if (extraCharges > 0) 16.height,

              // Subtotal row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(languages.lblSubTotal, style: secondaryTextStyle(size: 12)).flexible(fit: FlexFit.loose),
                  PriceWidget(
                    price: subTotal,
                    color: textPrimaryColorGlobal,
                    isBoldText: true,
                    size: 14,
                  ),
                ],
              ),
              16.height,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languages.lblNetAmount, style: secondaryTextStyle(size: 12)),
                      Text(languages.lblNetAmountFormula, style: secondaryTextStyle(size: 11)),
                    ],
                  ).flexible(fit: FlexFit.loose),
                  PriceWidget(
                    price: netAmount,
                    color: textPrimaryColorGlobal,
                    isBoldText: true,
                    size: 14,
                  ),
                ],
              ),
              16.height,

              // Tax row (if applicable)
              if (data.price != null && data.price! > 0)
                Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(languages.lblTax, style: secondaryTextStyle(size: 12)),
                            Text(' ($taxPercent%)', style: boldTextStyle(color: gradientBlue, size: 12)).expand()
                          ],
                        ).expand(),
                        16.width,
                        PriceWidget(
                          price: tax,
                          color: Colors.red,
                          isBoldText: true,
                          size: 14,
                        ),
                      ],
                    ),
                    16.height,
                  ],
                ),

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(languages.lblGrandTotalAmount, style: secondaryTextStyle(size: 12)),
                  16.width,
                  PriceWidget(
                    price: subTotal,
                    color: gradientBlue,
                    size: 14,
                  ).flexible(flex: 3),
                ],
              ),
              16.height,

              // Advance Amount
              Column(
                children: [
                  Row(
                    children: [
                      Text('${languages.advancePayment} (${postJobDetail?.advancePercent ?? 0}%)', style: secondaryTextStyle(size: 12)).expand(),
                      16.width,
                      PriceWidget(
                        price: advance,
                        color: textPrimaryColorGlobal,
                        size: 14,
                      ),
                    ],
                  ),
                  16.height,
                ],
              ),
              Row(
                children: [
                  Text(languages.remainingAmount, style: secondaryTextStyle(size: 12)).expand(),
                  16.width,
                  PriceWidget(
                    price: remaining,
                    color: textPrimaryColorGlobal,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(
    String title,
    List<BidReviewItem> reviews, {
    String? reviewReportType,
    bool showReportOnReviews = false,
  }) {
    if (reviews.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(title, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        ...reviews.map(
          (r) => _buildReviewCard(
            r,
            reviewReportType: reviewReportType,
            showReportReview: showReportOnReviews &&
                reviewReportType != null &&
                r.id != null &&
                r.id! > 0,
          ),
        ).toList(),
      ],
    );
  }

  Widget _buildReviewCard(
    BidReviewItem r, {
    String? reviewReportType,
    bool showReportReview = false,
  }) {
    final rating = (r.rating ?? 0).toDouble();
    final dateStr = r.createdAt != null && r.createdAt!.isNotEmpty
        ? formatDate(r.createdAt, format: DATE_FORMAT_2)
        : '';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  r.raterName?.validate() ?? '',
                  style: boldTextStyle(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showReportReview && reviewReportType != null && r.id != null)
                IconButton(
                  tooltip: languages.lblReportReviewTitle,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(Icons.flag_outlined,
                      color: Colors.red, size: 20),
                  onPressed: () => _openReviewReportDialog(
                    reviewId: r.id!,
                    reviewType: reviewReportType,
                  ),
                ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            4.height,
            Text(dateStr, style: secondaryTextStyle(size: 12)),
          ],
          8.height,
          Row(
            children: [
              DisabledRatingBarWidget(
                rating: rating,
                size: 16,
                activeColor: getRatingBarColor(rating.round()),
              ),
              6.width,
              Text(
                '${rating.toInt()}/5',
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
          if ((r.review ?? '').trim().isNotEmpty) ...[
            8.height,
            Text(
              r.review!.trim(),
              style: secondaryTextStyle(size: 13),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExtraChargesBreakdown() {
    if (postJobDetail!.extraCharges.isEmpty) return SizedBox.shrink();

    // Calculate total of all extra charges
    num totalExtraCharges = postJobDetail!.extraCharges.fold(0, (sum, charge) => sum + ((charge.amount ?? 0) * (charge.quantity ?? 0)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(languages.lblExtraChargesBreakdown, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          width: context.width(),
          decoration: boxDecorationDefault(color: context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...postJobDetail!.extraCharges.map((charge) => _extraChargesDetails(charge)).toList(),
              8.height,
              Divider(color: context.dividerColor, thickness: 1),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(languages.lblTotalExtraCharges, style: boldTextStyle(size: 14)),
                  PriceWidget(
                    price: totalExtraCharges,
                    color: textPrimaryColorGlobal,
                    isBoldText: true,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _extraChargesDetails(ExtraChargesData charge) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(charge.title ?? '', style: secondaryTextStyle(size: 12)).expand(),
          Text('${charge.amount} × ', style: secondaryTextStyle(size: 12)),
          Text('${charge.quantity}', style: secondaryTextStyle(size: 12)),
          Text(' = ', style: secondaryTextStyle(size: 12)),
          PriceWidget(
            price: (charge.amount ?? 0) * (charge.quantity ?? 0),
            color: textPrimaryColorGlobal,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool isDate = false,
    Color? cardBackgroundColor,
    int? profileUserIdToReport,
    int? postJobIdToReport,
  }) {
    final bool showProfileFlag = profileUserIdToReport != null &&
        profileUserIdToReport != appStore.userId;
    final int jobReportId = postJobIdToReport ?? 0;
    final bool showJobPostFlag = jobReportId > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: cardBackgroundColor ?? context.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          3.height,
          Text(
            title,
            style: secondaryTextStyle(size: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          2.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: boldTextStyle(
                    size: isDate ? 8 : 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showProfileFlag) ...[
                4.width,
                Tooltip(
                  message: languages.lblReportProfileTitle,
                  child: InkWell(
                    onTap: () =>
                        _openProfileReportDialog(profileUserIdToReport),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.flag_outlined,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
              if (showJobPostFlag) ...[
                4.width,
                Tooltip(
                  message: languages.lblReportJob,
                  child: InkWell(
                    onTap: () => _openJobPostReportDialog(jobReportId),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.flag_outlined,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
