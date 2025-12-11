
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/extra_charges_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/hold_dialog.dart';
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
  Future<JobRequestDetailResponse?>? future;
  JobRequestDetailResponse? postJobDetail;

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
      appBarTitle: 'Bid Details',
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
      case RequestStatus.remainingPaid:
        message = languages.paymentCompletedDownloadInvoice;
        break;
      case RequestStatus.cancel:
        message = "This bid was cancelled";
        break;
    }

    return message;
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
      if (s == RequestStatus.inProgress || s == RequestStatus.hold || s == RequestStatus.done || s == RequestStatus.confirmDone) return 5;
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
      final labels = ['Accept', 'Advance', 'Advance P.', "Let's Start", 'Work'];
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((e) => Text(e, style: secondaryTextStyle(size: 12))).toList(),
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
            padding: EdgeInsets.only(bottom: 60, top: 16, right: 16, left: 16),
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
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildInfoCard(
                    icon: Icons.h_mobiledata,
                    iconColor: gradientBlue,
                    title: 'Title',
                    value: postJobDetail!.postRequest?.title?.validate() ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    title: 'Location',
                    value: "${postJobDetail!.postRequest?.city?.name}${(postJobDetail!.postRequest?.country?.name??'').isEmpty ? '' : ', ${postJobDetail!.postRequest?.country?.name}' }",
                  ),
                  _buildInfoCard(
                    icon: Icons.business_center,
                    iconColor: Colors.orange,
                    title: 'Job Type',
                    value: postJobDetail!.postRequest?.type.displayName.validate() ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.attach_money,
                    iconColor: Colors.green[600]!,
                    title: 'Rate Type',
                    value: postJobDetail!.postRequest?.priceType.displayName.validate() ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.event_available,
                    iconColor: Colors.blue,
                    title: 'Start Date',
                    value: formatDate(postJobDetail!.postRequest?.startDate?.toIso8601String().validate(),showDateWithTime: true),
                    isDate: true,
                  ),
                  _buildInfoCard(
                    icon: Icons.event_busy,
                    iconColor: Colors.red,
                    title: 'End Date',
                    value:  formatDate(postJobDetail!.postRequest?.endDate?.toIso8601String().validate(),showDateWithTime: true),
                    isDate: true,
                  ),
                  _buildInfoCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue,
                    title: 'Total Budget',
                    value: postJobDetail!.postRequest?.totalBudget?.validate().toPriceFormat() ?? '0',
                  ),
                  _buildInfoCard(
                    icon: Icons.groups,
                    iconColor: Colors.grey,
                    title: 'Proposals',
                    value: (postJobDetail!.postRequest?.postBidList.length??0).validate().toString(), // Simplified for now
                  ),
                  _buildInfoCard(
                    icon: Icons.person,
                    iconColor: Colors.indigo,
                    title: 'Provider',
                    value: postJobDetail!.provider?.displayName.validate() ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    iconColor: Colors.green,
                    title: 'Customer',
                    value:  postJobDetail!.customer?.displayName.validate() ?? '',
                  ),
                ],
              ),
              16.height,

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
                      'Status',
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
                    child: _gradientButton(context, 'Split Payment', () async {
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
                    child: AppButton(
                      text: 'Cancel',
                      textStyle: boldTextStyle(color: white, size: 16),
                      color: cancelled,
                      width: context.width(),
                      onTap: () async {
                        confirmationRequestDialog(context,RequestStatus.cancel);
                      },
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.advancePaid)
                _gradientButton(context, 'Start Work', () async {
                  confirmationRequestDialog(context, RequestStatus.inProcess);
                }).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.inProgress) Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'hold',
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
                    child: _gradientButton(context, 'Done', () async {
                      confirmationRequestDialog(context, RequestStatus.done);
                    }),
                  ),
                ]
              ).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.hold)
                _gradientButton(context, 'Resume Work', () async {
                  confirmationRequestDialog(context, RequestStatus.inProgress);
                }).paddingOnly(bottom: 24),
              if(postJobDetail!.status == RequestStatus.confirmDone) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, 'Complete', () async {
                      confirmationRequestDialog(context, RequestStatus.completed);
                    }),
                  ),
                  16.width,
                  Expanded(
                    child: AppButton(
                      text: '+ Extra Charges',
                      textStyle: boldTextStyle(color: white, size: 16),
                      color: addExtraCharge,
                      width: context.width(),
                      onTap: () async {
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
                      },
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 24),
              if([RequestStatus.advancePaid, RequestStatus.inProcess, RequestStatus.inProgress, RequestStatus.hold, RequestStatus.done, RequestStatus.confirmDone, RequestStatus.completed, RequestStatus.remainingPaid].contains(postJobDetail!.status)) Row(
                children: [
                  Expanded(
                    child: _gradientButton(context, 'Chat', () async {
                        final customerId = postJobDetail?.customer?.id;
                        if (customerId == null) {
                          toast(languages.somethingWentWrong);
                          return;
                        }
                        toast(languages.pleaseWaitWhileWeLoadChatDetails);
                        try {
                          final res = await FrobsterChatApi.openWithUser(userId: customerId, title: 'Direct Message');
                          Fluttertoast.cancel();
                          if (res.status && res.conversationId != 0) {
                            FrobsterChatThreadScreen(
                              conversationId: res.conversationId,
                              title: 'Direct Message',
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
                  if(postJobDetail!.status == RequestStatus.remainingPaid) 16.width,
                  if(postJobDetail!.status == RequestStatus.remainingPaid) Expanded(
                    child: AppButton(
                      text: 'Download',
                      textStyle: boldTextStyle(color: white, size: 16),
                      color: completed,
                      width: context.width(),
                      onTap: () async {
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
                      },
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 24),
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
        Text('Price Details', style: boldTextStyle(size: LABEL_TEXT_SIZE)),
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
                  Text('Rate (Unit Price)', style: secondaryTextStyle(size: 12)).expand(),
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
                  Text('Quantity', style: secondaryTextStyle(size: 12)).flexible(fit: FlexFit.loose),
                  16.width,
                  Text(quantity.toString(), style: boldTextStyle(size: 14)),
                ],
              ),
              16.height,

              // Total calculation row
              Row(
                children: [
                  Text('Total Amount', style: secondaryTextStyle(size: 12)).expand(),
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
                    Text('Extra Charges', style: secondaryTextStyle(size: 12)).expand(),
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
                  Text('Subtotal', style: secondaryTextStyle(size: 12)).flexible(fit: FlexFit.loose),
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
                      Text('Net Amount', style: secondaryTextStyle(size: 12)),
                      Text('(Subtotal - Tax)', style: secondaryTextStyle(size: 11)),
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
                            Text('Tax', style: secondaryTextStyle(size: 12)),
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
                  Text(
                      'Grand Total Amount', style: secondaryTextStyle(size: 12)
                  ),
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
                      Text('Advance Payment(${postJobDetail?.advancePercent ?? 0}%)', style: secondaryTextStyle(size: 12)).expand(),
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
                  Text('Remaining Amount', style: secondaryTextStyle(size: 12)).expand(),
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

  Widget _buildExtraChargesBreakdown() {
    if (postJobDetail!.extraCharges.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text('Extra Charges Breakdown', style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          width: context.width(),
          decoration: boxDecorationDefault(color: context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...postJobDetail!.extraCharges.map((charge) => _extraChargesDetails(charge)).toList(),
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
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          6.height,
          Text(
            title,
            style: secondaryTextStyle(size: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          4.height,
          Flexible(
            child: Text(
              value,
              style: boldTextStyle(
                size: isDate ? 9 : 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}