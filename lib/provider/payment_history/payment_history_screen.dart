import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/payment_history/shimmer/payment_history_shimmer.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/common.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import '../../utils/extensions/num_extenstions.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  PaymentHistoryScreenState createState() => PaymentHistoryScreenState();
}

class PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentData> list = [];
  Future<List<PaymentData>>? future;
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getPaymentHistory(page, list, (p0) {
      isLastPage = p0;
      setState(() {});
    });
  }

  String _translatePaymentStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'paid':                return languages.paid;
      case 'advanced_paid':
      case 'advance_paid':       return languages.advancePaid;
      case 'pending':            return languages.pending;
      case 'cancelled':
      case 'canceled':           return languages.cancelled;
      case 'failed':             return languages.failed;
      case 'rejected':           return languages.rejected;
      case 'completed':          return languages.completed;
      default:                   return raw ?? '-';
    }
  }

  String _translatePaymentType(String? raw) {
    switch ((raw ?? '').toLowerCase().replaceAll('_', '')) {
      case 'banktransfer':
      case 'bank':               return languages.lblBankTransfer;
      case 'paypal':             return 'PayPal';
      case 'stripe':             return 'Stripe';
      case 'razorpay':           return 'Razorpay';
      case 'cash':               return languages.cash;
      case 'wallet':             return languages.lblWallet;
      default:                   return raw ?? '-';
    }
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Text(
          text,
          style: boldTextStyle(color: Colors.white, size: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width, {TextAlign align = TextAlign.left}) {
    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text,
          style: primaryTextStyle(size: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: align,
        ),
      ),
    );
  }

  Widget _buildPaymentTable(List<PaymentData> payments, String serviceHeader) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom gradient header row
            Container(
              decoration: BoxDecoration(
                gradient: kAppPrimaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderCell(languages.serialNumber, 70),
                  _buildHeaderCell(serviceHeader, 140),
                  _buildHeaderCell(languages.users, 130),
                  _buildHeaderCell(languages.paymentType, 110),
                  _buildHeaderCell(languages.status, 90),
                  _buildHeaderCell(languages.dateAndTime, 140),
                  _buildHeaderCell(languages.amount, 100),
                ],
              ),
            ),
            // Data rows – ID column shows simple serial number (1, 2, 3…) instead of raw txn ID
            ...payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              final serialNo = (index + 1).toString();
              final formattedAmount = payment.totalAmount != null 
                  ? payment.totalAmount!.toPriceFormat()
                  : '\$0.00';
              
              // Get service name (for regular payments) or job title (for post job payments)
              final serviceOrJobName = payment.booking?.service?.name ?? '-';
              
              return Container(
                color: (index % 2) != 0 ? context.cardColor : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDataCell(serialNo, 70),
                    _buildDataCell(serviceOrJobName, 140),
                    _buildDataCell(
                      '${payment.customer?.firstName ?? ''} ${payment.customer?.lastName ?? ''}'.trim().isEmpty 
                          ? '-' 
                          : '${payment.customer?.firstName ?? ''} ${payment.customer?.lastName ?? ''}'.trim(),
                      130
                    ),
                    _buildDataCell(_translatePaymentType(payment.paymentType), 110),
                    SizedBox(
                      width: 90,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: kAppPrimaryGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text(
                              _translatePaymentStatus(payment.paymentStatus),
                              style: TextStyle(color: Colors.white, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildDataCell(
                      payment.dateTime == null 
                          ? '-' 
                          : formatDate(payment.dateTime?.toIso8601String(), showDateWithTime: true),
                      140
                    ),
                    _buildDataCell(formattedAmount, 100, align: TextAlign.right),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ).paddingSymmetric(horizontal: 16);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.paymentHistory,
      showLoader: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SnapHelperWidget<List<PaymentData>>(
          future: future,
          onSuccess: (list) {
            // Separate regular payments and post job payments
            final regularPayments = list.where((payment) => payment.booking?.bookingType != BOOKING_TYPE_USER_POST_JOB).toList();
            final postJobPayments = list.where((payment) => payment.booking?.bookingType == BOOKING_TYPE_USER_POST_JOB).toList();
            
            return AnimatedScrollView(
              crossAxisAlignment: CrossAxisAlignment.start,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                // Regular Payments Section
                if (regularPayments.isNotEmpty) ...[
                  Text(languages.lblRegularPayments, style: boldTextStyle(size: 16)).paddingOnly(left: 16, top: 16, bottom: 8),
                  _buildPaymentTable(regularPayments, languages.lblServices),
                  16.height,
                ],
                // Post Job Payments Section
                if (postJobPayments.isNotEmpty) ...[
                  Text(languages.lblJobRequestPayments, style: boldTextStyle(size: 16)).paddingOnly(left: 16, top: 8, bottom: 8),
                  _buildPaymentTable(postJobPayments, languages.jobRequest),
                ],
              ],
              onNextPage: () {
                if (!isLastPage) {
                  page = page++;

                  init();
                  setState(() {});
                }
              },
              onSwipeRefresh: () async {
                page = 1;
                init();
                setState(() {});
                return await 2.seconds.delay;
              },
            );
          },
          loadingWidget: PaymentHistoryShimmer(),
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
          }
        ),
      ),
    );
  }
}
