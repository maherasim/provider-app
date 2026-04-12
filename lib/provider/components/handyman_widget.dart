import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/handyman_add_update_screen.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/disabled_rating_bar_widget.dart';
import '../../components/social_icons_list.dart';

class HandymanWidget extends StatefulWidget {
  final double width;
  final UserData? data;
  final Function? onUpdate;

  HandymanWidget({required this.width, this.data, this.onUpdate});

  @override
  State<HandymanWidget> createState() => _HandymanWidgetState();
}

class _HandymanWidgetState extends State<HandymanWidget> {
  Future<void> changeStatus(int? id, int status) async {
    appStore.setLoading(true);

    Map request = {CommonKeys.id: id, UserKeys.status: status};

    await updateHandymanStatus(request).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString(), print: true);
      widget.onUpdate?.call();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String cleanedAddress = parseHtmlString(widget.data!.address.validate());
    print(widget.data?.address);
    return Stack(
      children: [
        Container(
          width: widget.width,
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: appStore.isDarkMode
                  ? context.scaffoldBackgroundColor
                  : white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                ),
                child: CachedImageWidget(
                  url: widget.data!.profileImage!.isNotEmpty
                      ? widget.data!.profileImage.validate()
                      : '',
                  width: context.width(),
                  height: 110,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(
                    topRight: defaultRadius.toInt(),
                    topLeft: defaultRadius.toInt()),
              ),
              Column(
                children: [
                  Column(
                    children: [
                      SocialIconsList(spacing: 5).center(),
                      5.height,
                      DisabledRatingBarWidget(
                        rating: widget.data!.handymanRating.validate(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        size: 14,
                      ),
                      5.height,
                      HandymanNameWidget(
                        name: widget.data!.displayName.validate(),
                        isHandymanAvailable: widget.data!.isHandymanAvailable,
                        size: 14,
                      ).center(),
                      // City - Address line (fallback 'n/a')
                      5.height,
                      Builder(builder: (context) {
                        final city = widget.data?.cityName.validate() ?? '';
                        final country = widget.data?.countryName.validate() ?? '';
                        final addr = cleanedAddress;
                        String display = '';
                        if (city.isNotEmpty && country.isNotEmpty) {
                          display = '$city - $country';
                        } else if (city.isNotEmpty) {
                          display = city;
                        } else if (country.isNotEmpty) {
                          display = country;
                        } else if (addr.isNotEmpty) {
                          display = addr;
                        } else {
                          display = 'n/a';
                        }
                        return Text(
                          display,
                          style: primaryTextStyle(size: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).center();
                      }),
                    ],
                  ),
                  // Phone + message shortcuts (hidden per product request; keep for restore)
                  // 16.height,
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     if (widget.data!.contactNumber.validate().isNotEmpty)
                  //       TextIcon(
                  //         onTap: () {
                  //           launchCall(widget.data!.contactNumber.validate());
                  //         },
                  //         prefix: Container(
                  //           padding: EdgeInsets.all(8),
                  //           decoration: boxDecorationWithRoundedCorners(
                  //             boxShape: BoxShape.circle,
                  //             backgroundColor:
                  //                 primaryColor.withValues(alpha: 0.1),
                  //           ),
                  //           child: Image.asset(calling,
                  //               color: primaryColor, height: 14, width: 14),
                  //         ),
                  //       ),
                  //     if (widget.data!.contactNumber.validate().isNotEmpty) 12.width,
                  //     // if (widget.data!.email.validate().isNotEmpty)
                  //     //   TextIcon(
                  //     //     onTap: () {
                  //     //       launchMail(widget.data!.email.validate());
                  //     //     },
                  //     //     prefix: Container(
                  //     //       padding: EdgeInsets.all(8),
                  //     //       decoration: boxDecorationWithRoundedCorners(
                  //     //         boxShape: BoxShape.circle,
                  //     //         backgroundColor:
                  //     //             primaryColor.withValues(alpha: 0.1),
                  //     //       ),
                  //     //       child: ic_message.iconImage(
                  //     //           size: 14, color: primaryColor),
                  //     //     ),
                  //     //   ),
                  //     if (widget.data!.contactNumber.validate().isNotEmpty)
                  //       TextIcon(
                  //         onTap: () async {
                  //           toast(languages.pleaseWaitWhileWeLoadChatDetails);
                  //           UserData? user = await userService.getUserNull(
                  //               email: widget.data!.email.validate());
                  //           if (user != null) {
                  //             Fluttertoast.cancel();
                  //             UserChatScreen(receiverUser: user)
                  //                 .launch(context);
                  //           } else {
                  //             Fluttertoast.cancel();
                  //             toast(
                  //                 "${widget.data!.firstName.validate()} ${languages.isNotAvailableForChat}");
                  //           }
                  //         },
                  //         prefix: Container(
                  //           padding: EdgeInsets.all(8),
                  //           decoration: boxDecorationWithRoundedCorners(
                  //             boxShape: BoxShape.circle,
                  //             backgroundColor:
                  //                 primaryColor.withValues(alpha: 0.1),
                  //           ),
                  //           child: Image.asset(textMsg,
                  //               color: primaryColor, height: 14, width: 14),
                  //         ),
                  //       ),
                  //   ],
                  // ).fit(),
                ],
              ).paddingSymmetric(vertical: 16),
            ],
          ),
        ).onTap(() {
          HandymanAddUpdateScreen(
            userType: USER_TYPE_HANDYMAN,
            data: widget.data,
            onUpdate: () {
              widget.onUpdate?.call();
            },
          ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
        }, borderRadius: radius()),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: boxDecorationWithRoundedCorners(
              boxShape: BoxShape.circle,
              backgroundColor: context.cardColor,
            ),
            alignment: Alignment.center,
            child: !widget.data!.isActive
                ? Image.asset(block, width: 18, height: 18)
                : Image.asset(unBlock, width: 18, height: 18),
          ).onTap(() {
            ifNotTester(context, () {
              if (!widget.data!.isActive) {
                changeStatus(widget.data!.id, 1);
              } else {
                changeStatus(widget.data!.id, 0);
              }
              widget.data!.isActive = !widget.data!.isActive;
            });
            setState(() {});
          }),
        )
      ],
    );
  }
}
