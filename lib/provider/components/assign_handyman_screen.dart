import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../../components/handyman_add_update_screen.dart';
import '../../utils/constant.dart';
import '../../utils/colors.dart';

class AssignHandymanScreen extends StatefulWidget {
  final int? bookingId;
  final Function? onUpdate;
  final int? serviceAddressId;

  const AssignHandymanScreen({Key? key, this.onUpdate, required this.bookingId, required this.serviceAddressId}) : super(key: key);

  @override
  _AssignHandymanScreenState createState() => _AssignHandymanScreenState();
}

class _AssignHandymanScreenState extends State<AssignHandymanScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController _commissionController = TextEditingController();

  Future<List<UserData>>? future;
  List<UserData> handymanList = [];

  int page = 1;
  bool isLastPage = false;

  UserData? userListData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getAllHandyman(
      page: page,
      serviceAddressId: widget.serviceAddressId,
      userData: handymanList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  Future<void> _handleAssignHandyman() async {
    if (appStore.isLoading) return;

    // Pre-fill with the selected handyman's default commission
    final defaultCommission = userListData?.handymanCommission?.toString() ?? '';
    _commissionController.text = defaultCommission;

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
                '${languages.lblAreYouSureYouWantToAssignThisServiceTo(userListData!.firstName.validate())}',
                style: boldTextStyle(),
              ),
              16.height,
              // Commission input
              Text(languages.commission, style: secondaryTextStyle()),
              8.height,
              TextFormField(
                controller: _commissionController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '1 – 99',
                  suffixText: '%',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
                      onTap: () async {
                        final commissionVal = double.tryParse(_commissionController.text.trim());
                        if (commissionVal == null || commissionVal < 1 || commissionVal > 99) {
                          toast(languages.commissionRange);
                          return;
                        }
                        finish(context);
                        var request = {
                          CommonKeys.id: widget.bookingId,
                          CommonKeys.handymanId: [userListData!.id.validate()],
                          'handyman_commission': commissionVal,
                        };

                        appStore.setLoading(true);

                        await assignBooking(request).then((res) async {
                          appStore.setLoading(false);

                          widget.onUpdate?.call();

                          finish(context);

                          toast(res.message);
                        }).catchError((e) {
                          appStore.setLoading(false);

                          toast(e.toString());
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

  Future<void> _handleAssignToMyself() async {
    if (appStore.isLoading) return;

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
              Text(languages.lblAreYouSureYouWantToAssignToYourself, style: boldTextStyle()),
              16.height,
              Row(
                children: [
                  AppButton(
                    text: languages.lblCancel,
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
                      onTap: () async {
                        finish(context);
                        var request = {
                          CommonKeys.id: widget.bookingId,
                          CommonKeys.handymanId: [appStore.userId.validate()],
                        };

                        appStore.setLoading(true);

                        await assignBooking(request).then((res) async {
                          appStore.setLoading(false);

                          widget.onUpdate!.call();

                          finish(context);

                          toast(res.message);
                        }).catchError((e) {
                          appStore.setLoading(false);

                          toast(e.toString());
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

  Widget buildHandymanItem({required UserData userData}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CachedImageWidget(
          url: userData.profileImage!.isNotEmpty
              ? userData.profileImage.validate()
              : "",
          height: 60,
          fit: BoxFit.cover,
          circle: true,
        ),
        16.width,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Marquee(
              child: HandymanNameWidget(
                size: 14,
                name: userData.displayName.validate(),
                isHandymanAvailable: userData.isHandymanAvailable,
              ),
            ),
            if (userData.handymanType.validate().isNotEmpty) 4.height,
            if (userData.handymanType.validate().isNotEmpty)
              Row(
                children: [
                  Text(
                    "${userData.handymanType.validate()}",
                    style: secondaryTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.width,
                  Flexible(
                    child: Text(
                      "(${userData.handymanCommission.validate()} ${languages.commission})",
                      style: secondaryTextStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            4.height,
            if (userData.designation.validate().isNotEmpty)
              Text(
                "${userData.designation.validate()}",
                style: secondaryTextStyle(),
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                "${languages.lblMemberSince} ${DateTime.parse(userData.createdAt.validate()).year}",
                style: secondaryTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ).flexible(),
      ],
    );
  }

  Widget buildRadioListTile({required UserData userData}) {
    if(!userData.isHandymanAvailable.validate()){
      return buildHandymanItem(userData: userData).paddingSymmetric(vertical: 13, horizontal: 16);
    }
    final isSelected = userListData == userData;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      title: buildHandymanItem(userData: userData),
      trailing: GestureDetector(
        onTap: () {
          if (userData.isHandymanAvailable.validate()) {
            if (userListData == userData) {
              userListData = null;
              _commissionController.clear();
              setState(() {});
            } else {
              userListData = userData;
              _commissionController.text = userData.handymanCommission?.toString() ?? '';
              setState(() {});
            }
          } else {
            Fluttertoast.cancel();
            toast(languages.lblHandymanIsOffline);
          }
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.transparent : (appStore.isDarkMode ? Colors.white70 : Colors.black54),
              width: 2,
            ),
          ),
          child: isSelected
              ? Container(
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kAppPrimaryGradient,
                  ),
                )
              : null,
        ),
      ),
      onTap: () {
        if (userData.isHandymanAvailable.validate()) {
          if (userListData == userData) {
            userListData = null;
            _commissionController.clear();
            setState(() {});
          } else {
            userListData = userData;
            _commissionController.text = userData.handymanCommission?.toString() ?? '';
            setState(() {});
          }
        } else {
          Fluttertoast.cancel();
          toast(languages.lblHandymanIsOffline);
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.lblAssignHandyman,
      body: Stack(
        children: [
          SnapHelperWidget<List<UserData>>(
            future: future,
            loadingWidget: LoaderWidget(),
            onSuccess: (snap) {
              return AnimatedListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                padding: EdgeInsets.only(top: 8, bottom: 90),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                  title: languages.noHandymanAvailable,
                  imageWidget: EmptyStateWidget(),
                  retryText: languages.lblAddHandyman,
                  onRetry: () {
                    HandymanAddUpdateScreen(
                      userType: USER_TYPE_HANDYMAN,
                      onUpdate: () {
                        init();
                        setState(() {});
                      },
                    ).launch(context);
                  },
                ),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                itemBuilder: (BuildContext context, index) {
                  return Column(
                    children: [
                      buildRadioListTile(userData: snap[index]).paddingOnly(bottom: 2, top: 2),
                      Divider(endIndent: 16.0, indent: 16.0, height: 0, color: context.dividerColor),
                    ],
                  );
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                disposeScrollController: false,
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
          Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: Row(
              children: [
                // AppButton(
                //   onTap: () {
                //     _handleAssignToMyself();
                //   },
                //   width: context.width(),
                //   shapeBorder: RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: context.primaryColor)),
                //   color: context.scaffoldBackgroundColor,
                //   elevation: 0,
                //   textColor: context.primaryColor,
                //   text: languages.lblAssignToMyself,
                // ).expand(),
                // if (userListData != null) 16.width,
                if (userListData != null)
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: kAppPrimaryGradient, borderRadius: radius(8)),
                    child: AppButton(
                      onTap: () {
                        if (userListData != null) {
                          _handleAssignHandyman();
                        } else {
                          toast(languages.lblSelectHandyman);
                        }
                      },
                      color: Colors.transparent,
                      width: context.width(),
                      text: languages.lblAssign,
                      textStyle: boldTextStyle(color: white),
                      elevation: 0,
                    ),
                  ).expand(),
              ],
            ),
          ),
          Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading),
          )
        ],
      ),
    );
  }
}
