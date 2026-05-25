import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalEarningWidget extends StatelessWidget {
  const TotalEarningWidget({Key? key, required this.totalEarning})
      : super(key: key);

  final TotalData totalEarning;

  String _localizedPaymentMethod(String paymentMethod) {
    String method = paymentMethod.validate().toLowerCase().replaceAll(' ', '_');

    if (method == PAYMENT_METHOD_FROM_WALLET) return languages.lblWallet;
    if (method == PAYMENT_METHOD_COD) return languages.cash;
    if (method == 'bank_transfer') return languages.lblBankTransfer;

    return paymentMethod
        .validate()
        .replaceAll('_', ' ')
        .capitalizeFirstLetter();
  }

  String _localizedDescription(String description) {
    String value = description.validate();
    RegExpMatch? match = RegExp(
      r'^(advance|remaining|remaing)\s+payout\s+for\s+bid\s+#?(\d+)$',
      caseSensitive: false,
    ).firstMatch(value);

    if (match == null) return value;

    String bidNumber = match.group(2).validate();
    bool isAdvancePayout = match.group(1).validate().toLowerCase() == 'advance';

    if (appStore.selectedLanguageCode == 'de') {
      return isAdvancePayout
          ? 'Vorauszahlung für Gebot #$bidNumber'
          : 'Restzahlung für Gebot #$bidNumber';
    }

    return isAdvancePayout
        ? 'Advance payout for Bid #$bidNumber'
        : 'Remaining payout for Bid #$bidNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.scaffoldBackgroundColor,
        border: Border.all(color: context.dividerColor, width: 1.0),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(languages.paymentMethod, style: primaryTextStyle()),
              Text(
                _localizedPaymentMethod(totalEarning.paymentMethod.validate()),
                style: boldTextStyle(color: primaryColor),
              ),
            ],
          ),
          if (totalEarning.description.validate().isNotEmpty)
            Column(
              children: [
                16.height,
                Text(_localizedDescription(totalEarning.description.validate()),
                    style: secondaryTextStyle()),
              ],
            ),
          16.height,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: radius(),
            ),
            width: context.width(),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblAmount,
                        style: secondaryTextStyle(size: 14)),
                    16.width,
                    PriceWidget(
                            price: totalEarning.amount.validate(),
                            color: primaryColor,
                            isBoldText: true,
                            size: 14)
                        .flexible(),
                  ],
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblDate,
                        style: secondaryTextStyle(size: 14)),
                    Text(
                      formatDate(totalEarning.createdAt.validate().toString(),
                          format: DATE_FORMAT_9),
                      style: boldTextStyle(size: 14),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
