import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_widgets.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../models/booking_detail_response.dart';
import '../../../networks/rest_apis.dart';
import '../../../utils/common.dart';
import '../../../utils/colors.dart';
import 'add_addon_service_screen.dart';

class AddonServiceListScreen extends StatefulWidget {
  @override
  _AddonServiceListScreenState createState() => _AddonServiceListScreenState();
}

class _AddonServiceListScreenState extends State<AddonServiceListScreen> {
  Future<List<ServiceAddon>>? future;
  List<ServiceAddon> addonServiceList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
    });
  }

  void init() async {
    future = getAddonsServiceList(
      addonServiceData: addonServiceList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  // region Delete Package
  void removeAddonService({int? addonId}) {
    deleteAddonService(addonId.validate()).then((value) async {
      toast(value.message.validate());
      init();

      setState(() {});
      await 2.seconds.delay;
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  Future<void> confirmationDialog(
      {required ServiceAddon addonServiceData}) async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (_) {
        return Container(
          decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${languages.areYouSureWantToDeleteThe} ${addonServiceData.name.validate()} ${languages.addOns}?',
                style: boldTextStyle(),
              ),
              16.height,
              Row(
                children: [
                  AppButton(
                    text: languages.lblNo,
                    elevation: 0,
                    color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                    textColor: textPrimaryColorGlobal,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  16.width,
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                    child: AppButton(
                      text: languages.lblYes,
                      elevation: 0,
                      color: Colors.transparent,
                      textStyle: boldTextStyle(color: white),
                      onTap: () {
                        finish(context);
                        ifNotTester(context, () {
                          appStore.setLoading(true);
                          removeAddonService(addonId: addonServiceData.id.validate());
                          setState(() {});
                        });
                      },
                    ),
                  ).expand(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.addOns,
      actions: [
        IconButton(
          icon: Icon(Icons.add, size: 28, color: white),
          onPressed: () async {
            bool? res = await AddAddonServiceScreen().launch(context);

            if (res ?? false) {
              appStore.setLoading(true);
              init();

              setState(() {});
            }
          },
        ),
      ],
      body: Stack(
        children: [
          SnapHelperWidget<List<ServiceAddon>>(
            future: future,
            loadingWidget: LoaderWidget(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                  title: languages.oppsLooksLikeYou,
                  imageWidget: EmptyStateWidget(),
                ).paddingSymmetric(horizontal: 16),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

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
                itemBuilder: (BuildContext context, index) {
                  ServiceAddon data = snap[index];

                  return Container(
                    width: context.width(),
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.only(
                        top: 16, bottom: 16, left: 16, right: 8),
                    decoration: boxDecorationRoundedWithShadow(
                        defaultRadius.toInt(),
                        backgroundColor: context.cardColor),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedImageWidget(
                          url: data.serviceAddonImage.validate().isNotEmpty
                              ? data.serviceAddonImage.validate()
                              : '',
                          height: 70,
                          fit: BoxFit.cover,
                          radius: defaultRadius,
                        ),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            4.height,
                            Marquee(
                                child: Text(
                                    data.name
                                        .validate()
                                        .capitalizeFirstLetter(),
                                    style: boldTextStyle())),
                            4.height,
                            if (data.serviceName.isNotEmpty)
                              Text('${data.serviceName.validate()}',
                                      style: secondaryTextStyle())
                                  .paddingBottom(4),
                            PriceWidget(
                              price: data.price.validate(),
                              hourlyTextColor: Colors.white,
                              size: 16,
                            ),
                          ],
                        ).expand(),
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert,
                              size: 24, color: context.iconColor),
                          color: context.scaffoldBackgroundColor,
                          padding: EdgeInsets.all(8),
                          onSelected: (selection) async {
                            if (selection == 1) {
                              bool? res = await AddAddonServiceScreen(
                                      addonServiceData: data)
                                  .launch(context);

                              if (res ?? false) {
                                appStore.setLoading(true);
                                init();

                                setState(() {});
                              }
                            } else if (selection == 2) {
                              confirmationDialog(addonServiceData: data);
                            }
                          },
                          itemBuilder: (context) => [
                            // if (rolesAndPermissionStore.serviceAddOnEdit)
                              PopupMenuItem(
                                  child: Text(languages.lblEdit,
                                      style: boldTextStyle()),
                                  value: 1),
                            // if (rolesAndPermissionStore.serviceAddOnDelete)
                              PopupMenuItem(
                                  child: Text(languages.lblDelete,
                                      style: boldTextStyle()),
                                  value: 2),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
