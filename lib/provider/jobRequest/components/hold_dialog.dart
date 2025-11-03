import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/post_job_data.dart';

class HoldReasonDialog extends StatefulWidget {
  final JobRequestDetailResponse data;

  HoldReasonDialog({required this.data});

  @override
  _HoldReasonDialogState createState() => _HoldReasonDialogState();
}

class _HoldReasonDialogState extends State<HoldReasonDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  void _handleSubmitClick() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);
      final request = {
        "status": RequestStatus.hold.backendValue,
        "hold_reason": reason.text,
      };

      await bidUpdate(widget.data.id.validate(),request).then((res) async {
        appStore.setLoading(false);

        toast(res.message.validate());
        finish(context, true);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
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
                  Container(
                    decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.doYouWantToHoldThisBid, style: boldTextStyle()),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.MULTILINE,
                          controller: reason,
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
                            hintText: languages.lblReason,
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
