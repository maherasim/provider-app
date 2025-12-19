import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/configs.dart';
import '../utils/colors.dart';

class AddSkillComponent extends StatefulWidget {
  const AddSkillComponent({Key? key}) : super(key: key);

  @override
  State<AddSkillComponent> createState() => _AddSkillComponentState();
}

class _AddSkillComponentState extends State<AddSkillComponent> {
  TextEditingController skillsCont = TextEditingController();

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
    return Container(
      width: context.width(),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.width(),
            decoration: BoxDecoration(
              gradient: kAppPrimaryGradient,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.addEssentialSkill, style: boldTextStyle(color: white)).expand(),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: skillsCont,
            decoration: inputDecoration(context, hint: languages.essentialSkills,fillColor: Colors.black),
          ).paddingAll(16),
          16.height,
          DecoratedBox(
            decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
            child: AppButton(
              text: languages.btnSave,
              color: Colors.transparent,
              elevation: 0,
              textStyle: boldTextStyle(color: white),
              width: context.width() - context.navigationBarHeight,
              onTap: () {
                if (skillsCont.text.isNotEmpty) {
                  finish(context, skillsCont.text);
                } else {
                  toast(languages.pleaseAddEssentialSkill);
                }
              },
            ),
          ).paddingAll(16),
        ],
      ),
    );
  }
}
