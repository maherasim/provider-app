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
            return AnimatedScrollView(
              crossAxisAlignment: CrossAxisAlignment.start,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
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
                              _buildHeaderCell("ID", 70),
                              _buildHeaderCell("Service", 140),
                              _buildHeaderCell("Users", 130),
                              _buildHeaderCell("Payment Type", 110),
                              _buildHeaderCell("Status", 90),
                              _buildHeaderCell("Date & Time", 140),
                              _buildHeaderCell("Amount", 100),
                            ],
                          ),
                        ),
                        // Data rows
                        ...list.asMap().entries.map((entry) {
                          final index = entry.key;
                          final payment = entry.value;
                          final formattedAmount = payment.totalAmount != null 
                              ? payment.totalAmount!.toPriceFormat()
                              : '\$0.00';
                          
                          return Container(
                            color: (index % 2) != 0 ? context.cardColor : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDataCell(payment.txnId ?? '-', 70),
                                _buildDataCell(payment.booking?.service?.name ?? '-', 140),
                                _buildDataCell(
                                  '${payment.customer?.firstName ?? ''} ${payment.customer?.lastName ?? ''}'.trim().isEmpty 
                                      ? '-' 
                                      : '${payment.customer?.firstName ?? ''} ${payment.customer?.lastName ?? ''}'.trim(),
                                  130
                                ),
                                _buildDataCell(payment.paymentType ?? '-', 110),
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
                                          payment.paymentStatus ?? '-',
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
                )
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