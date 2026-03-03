import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';


class SplitPaymentDialog extends StatefulWidget {
  final JobRequestDetailResponse data;

  SplitPaymentDialog({required this.data});

  @override
  _SplitPaymentDialogState createState() => _SplitPaymentDialogState();
}

class _SplitPaymentDialogState extends State<SplitPaymentDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController advance = TextEditingController();
  TextEditingController remaining = TextEditingController();

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

      Map request = {
        "advance_percent": advance.text.validate().toInt(),
        "remaining_percent": remaining.text.validate().toInt()
      };

      splitPayment(widget.data.id.validate() ,request).then((value) {
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
                  Container(
                    decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.updatePaymentSplit, style: boldTextStyle()),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: advance,
                          isValidationRequired: true,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return context.translate.hintRequired;
                            }
                            final advanceValue = int.tryParse(value.trim());
                            if (advanceValue == null) return 'Please enter a valid number';
                            if (advanceValue < 20 || advanceValue > 99) {
                              return 'Advance payment must be between 20 and 99';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final advanceValue = int.tryParse(value ?? '') ?? 0;
                            remaining.text = '${100 - advanceValue}';
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: '${languages.advancePercentage} (20-99)',
                            hintStyle: secondaryTextStyle(),
                            prefixText: "% ",
                            prefixStyle: primaryTextStyle(size: 16),
                          ),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: remaining,
                          isValidationRequired: true,
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.translate.hintRequired;
                            }
                            return null;
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: languages.remainingPercentage,
                            hintStyle: secondaryTextStyle(),
                            prefixText: "% ",
                            prefixStyle: primaryTextStyle(size: 16),
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
                      Expanded(
                        child: InkWell(
                          borderRadius: radius(),
                          onTap: _handleSubmitClick,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: radius(),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.red, Colors.blue],
                              ),
                            ),
                            child: Text(
                              languages.confirm,
                              style: boldTextStyle(color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
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
