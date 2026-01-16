import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanCommissionComponent extends StatelessWidget {
  final Commission commission;

  HandymanCommissionComponent({required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: appStore.isDarkMode ? cardDarkColor : gray.withValues(alpha:0.1),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichTextWidget(
                textAlign: TextAlign.center,
                list: [
                  TextSpan(text: "Worker type: ", style: secondaryTextStyle()),
                  TextSpan(text: 'Commission', style: boldTextStyle()),
                ],
              ),
              8.height,
              Builder(
                builder: (context) {
                  // Check if type is percent or percentage
                  String commissionType = commission.type.validate().toLowerCase();
                  bool isPercent = commissionType == COMMISSION_TYPE_PERCENT || 
                                  commissionType == COMMISSION_TYPE_PERCENTAGE;
                  
                  // Format commission value - remove decimals if whole number
                  num commissionValue = commission.commission.validate();
                  String formattedCommission = isPercent 
                      ? (commissionValue % 1 == 0 
                          ? commissionValue.toInt().toString() 
                          : commissionValue.toString())
                      : commissionValue.toString();
                  
                  return RichTextWidget(
                    textAlign: TextAlign.center,
                    list: [
                      TextSpan(text: '${languages.lblMyCommission}: ', style: secondaryTextStyle()),
                      TextSpan(
                        text: isPercent 
                            ? '$formattedCommission %'
                            : '${appConfigurationStore.currencySymbol}$formattedCommission',
                        style: boldTextStyle(),
                      ),
                      if (isPercent)
                        TextSpan(
                          text: ' (${languages.lblFixed})',
                          style: secondaryTextStyle(),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
            child: Image.asset(percent_line, height: 22, width: 22, color: white),
          ),
        ],
      ),
    );
  }
}
