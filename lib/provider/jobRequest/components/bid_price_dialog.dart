import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/post_job_data.dart';

class BidPriceDialog extends StatefulWidget {
  final PostJobData data;
  final num? price;
  final String? whyText;
  final bool isUpdateBid;

  BidPriceDialog({required this.data, this.price, this.whyText, this.isUpdateBid = false});

  @override
  _BidPriceDialogState createState() => _BidPriceDialogState();
}

class _BidPriceDialogState extends State<BidPriceDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController servicePrice = TextEditingController();
  TextEditingController whyChooseMe = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
    servicePrice.text = widget.price?.toString() ?? '';
    whyChooseMe.text = widget.whyText ?? '';
  }

  void _handleSubmitClick() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map request = {
        SaveBidding.postRequestId: widget.data.id.validate(),
        SaveBidding.providerId: appStore.userId.validate(),
        SaveBidding.price: servicePrice.text.validate(),
        SaveBidding.whyChooseMe: whyChooseMe.text.validate(),
      };

      saveBid(request).then((value) {
        appStore.setLoading(false);

        toast(value.message.validate());
        finish(context, true);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: context.width(),
        color: Colors.transparent,
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(widget.isUpdateBid) Center(child: Text("Update Bid", style: boldTextStyle())).paddingBottom(16),
                  Container(
                    decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.giveYourEstimatePriceHere, style: boldTextStyle()),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: servicePrice,
                          isValidationRequired: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.translate.hintRequired;
                            }
                            /*if (value!.isEmpty) {
                              return languages.hintRequired;
                            } else if (value.toInt() <= 0) {
                              return languages.pleaseEnterValidBidPrice;
                            } else if (widget.data.price.validate() > num.parse(value.validate())) {
                              return "${languages.yourPriceShouldNotBeLessThan} ${widget.data.price.validate()}";
                            }*/
                            return null;
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: languages.enterBidPrice,
                            hintStyle: secondaryTextStyle(),
                            prefixText: appConfigurationStore.currencySymbol + " ",
                            prefixStyle: primaryTextStyle(size: 16),
                          ),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.MULTILINE,
                          controller: whyChooseMe,
                          isValidationRequired: true,
                          maxLines: 3,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.translate.hintRequired;
                            }
                            /*if (value!.isEmpty) {
                              return languages.hintRequired;
                            } else if (value.toInt() <= 0) {
                              return languages.pleaseEnterValidBidPrice;
                            } else if (widget.data.price.validate() > num.parse(value.validate())) {
                              return "${languages.yourPriceShouldNotBeLessThan} ${widget.data.price.validate()}";
                            }*/
                            return null;
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: languages.whyChooseMe,
                            hintStyle: secondaryTextStyle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          finish(context);
                        },
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                        color: context.scaffoldBackgroundColor,
                        text: languages.lblCancel,
                        textColor: context.iconColor,
                      ).expand(),
                      16.width,
                      AppButton(
                        onTap: _handleSubmitClick,
                        color: context.primaryColor,
                        text: languages.confirm,
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ).paddingAll(16),
            Observer(builder: (context) {
              return LoaderWidget().visible(appStore.isLoading);
            })
          ],
        ).center(),
      ),
    );
  }
}
