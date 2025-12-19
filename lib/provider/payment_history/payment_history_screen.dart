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
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: boldTextStyle(color: Colors.white),
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
                            children: [
                              _buildHeaderCell("ID", 80),
                              _buildHeaderCell("Service", 120),
                              _buildHeaderCell("Users", 120),
                              _buildHeaderCell("Payment Type", 120),
                              _buildHeaderCell("Status", 100),
                              _buildHeaderCell("Date & Time", 150),
                              _buildHeaderCell("Amount", 100),
                            ],
                          ),
                        ),
                        // DataTable without header
                        DataTable(
                          headingRowHeight: 0,
                          headingTextStyle: boldTextStyle(),
                          dataTextStyle: primaryTextStyle(),
                          dividerThickness: 0,
                          columns: [
                            DataColumn(label: SizedBox(width: 80)),
                            DataColumn(label: SizedBox(width: 120)),
                            DataColumn(label: SizedBox(width: 120)),
                            DataColumn(label: SizedBox(width: 120)),
                            DataColumn(label: SizedBox(width: 100)),
                            DataColumn(label: SizedBox(width: 150)),
                            DataColumn(label: SizedBox(width: 100)),
                          ],
                          rows: list.map((payment) {
                            return DataRow(
                              color: (list.indexOf(payment) % 2) != 0 ? WidgetStatePropertyAll(context.cardColor) : null,
                              cells: [
                                DataCell(Text(payment.txnId ?? '')),
                                DataCell(Text(payment.booking?.service?.name ?? '')),
                                DataCell(Text('${payment.customer?.firstName ?? ' '} ${payment.customer?.lastName ?? ' '}')),
                                DataCell(Text(payment.paymentType ?? '')),
                                DataCell(DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: kAppPrimaryGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      payment.paymentStatus ?? '',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )),
                                DataCell(Text( payment.dateTime == null ? '' : formatDate(payment.dateTime?.toIso8601String(), showDateWithTime: true))),
                                DataCell(Text("\$${payment.totalAmount}")),
                              ],
                            );
                          }).toList(),
                        ),
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