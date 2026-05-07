import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/colors.dart';

class AddReasonsComponent extends StatefulWidget {
  const AddReasonsComponent({Key? key}) : super(key: key);

  @override
  State<AddReasonsComponent> createState() => _AddReasonsComponentState();
}

class _AddReasonsComponentState extends State<AddReasonsComponent> {
  TextEditingController reasonsCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.width(),
            decoration: BoxDecoration(
              gradient: kAppPrimaryGradient,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.addReason, style: boldTextStyle(color: white))
                    .expand(),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: reasonsCont,
            decoration: inputDecoration(context,
                hint: languages.writeReason,
                fillColor: context.scaffoldBackgroundColor),
          ).paddingAll(16),
          DecoratedBox(
            decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
            child: AppButton(
              text: languages.btnSave,
              color: Colors.transparent,
              elevation: 0,
              textStyle: boldTextStyle(color: white),
              width: context.width() - context.navigationBarHeight,
              onTap: () {
                if (reasonsCont.text.isNotEmpty) {
                  finish(context, reasonsCont.text);
                } else {
                  toast(languages.pleaseAddReason);
                }
              },
            ),
          ).paddingAll(16),
        ],
      ),
    ).paddingAll(0);
  }
}
