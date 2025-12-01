import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  LanguagesScreenState createState() => LanguagesScreenState();
}

class LanguagesScreenState extends State<LanguagesScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshList() async {
    dayListMap = {
      languages.mon: "mon",
      languages.tue: "tue",
      languages.wed: "wed",
      languages.thu: "thu",
      languages.fri: "fri",
      languages.sat: "sat",
      languages.sun: "sun",
    };
    daysList = [
      languages.mon,
      languages.tue,
      languages.wed,
      languages.thu,
      languages.fri,
      languages.sat,
      languages.sun,
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(languages.language, style: boldTextStyle(color: Colors.white, size: APP_BAR_TEXT_SIZE)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: BackWidget(color: Colors.white),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: kAppPrimaryGradient)),
      ),
      body: LanguageListWidget(
        widgetType: WidgetType.LIST,
        onLanguageChange: (v) async {
          appStore.setLanguage(v.languageCode!).then((v) {
            refreshList();
          });
          setState(() {});
          finish(context);
        },
      ),
    );
  }
}
