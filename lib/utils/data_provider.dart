import 'package:flutter/cupertino.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/about_model.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';

List<AboutModel> getAboutDataModel({BuildContext? context}) {
  List<AboutModel> aboutList = [];

  aboutList.add(AboutModel(title: context!.translate.lblTermsAndConditions, image: termCondition, type: AboutType.terms));
  aboutList.add(AboutModel(title: languages.lblPrivacyPolicy, image: privacy_policy, type: AboutType.privacy));
  aboutList.add(AboutModel(title: languages.lblHelpAndSupport, image: termCondition, type: AboutType.helpSupport));
  aboutList.add(AboutModel(title: languages.lblHelpLineNum, image: calling, type: AboutType.helpline));
  aboutList.add(AboutModel(title: languages.lblRateUs, image: rateUs, type: AboutType.rateUs));

  return aboutList;
}
