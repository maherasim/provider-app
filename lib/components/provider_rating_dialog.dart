import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderRatingDialog extends StatefulWidget {
  final int bookingId;
  final int customerId;
  final String? customerName;
  final String? customerImage;
  final String? customerCity;
  final String? customerCountry;
  final num? customerRating;
  final int? customerTotalRatings;

  ProviderRatingDialog({
    required this.bookingId,
    required this.customerId,
    this.customerName,
    this.customerImage,
    this.customerCity,
    this.customerCountry,
    this.customerRating,
    this.customerTotalRatings,
  });

  @override
  _ProviderRatingDialogState createState() => _ProviderRatingDialogState();
}

class _ProviderRatingDialogState extends State<ProviderRatingDialog> {
  double rating = 0.0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (rating == 0.0) {
      toast('Please select a rating');
      return;
    }

    appStore.setLoading(true);

    Map request = {
      CommonKeys.bookingId: widget.bookingId,
      CommonKeys.customerId: widget.customerId,
      CommonKeys.rating: rating,
      CommonKeys.review: reviewController.text.trim(),
    };

    saveProviderRating(request).then((res) {
      appStore.setLoading(false);
      toast(res.message.validate());
      finish(context, true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(12)),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.customerImage.validate().isNotEmpty)
                CachedImageWidget(
                  url: widget.customerImage.validate(),
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  radius: defaultRadius,
                )
              else
                Container(
                  height: 50,
                  width: 50,
                  decoration: boxDecorationDefault(shape: BoxShape.circle),
                  child: Icon(Icons.person, size: 30, color: context.iconColor),
                ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languages.rateYourExperience,
                      style: boldTextStyle(size: 18),
                    ),
                    4.height,
                    if (widget.customerName.validate().isNotEmpty)
                      Text(
                        'With ${widget.customerName.validate()}',
                        style: secondaryTextStyle(),
                      ),
                    if (widget.customerCity.validate().isNotEmpty || widget.customerCountry.validate().isNotEmpty) ...[
                      2.height,
                      Text(
                        [
                          widget.customerCity.validate(),
                          widget.customerCountry.validate(),
                        ].where((e) => e.isNotEmpty).join(', '),
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                    if (widget.customerRating != null && widget.customerRating! > 0) ...[
                      4.height,
                      Row(
                        children: [
                          DisabledRatingBarWidget(
                            rating: widget.customerRating!,
                            size: 14,
                          ),
                          4.width,
                          if (widget.customerTotalRatings != null && widget.customerTotalRatings! > 0)
                            Text(
                              '(${widget.customerTotalRatings})',
                              style: secondaryTextStyle(size: 12),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          24.height,
          Center(
            child: RatingBarWidget(
              onRatingChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
              itemCount: 5,
              size: 40,
              rating: rating,
              activeColor: getRatingBarColor(rating.toInt()),
            ),
          ),
          24.height,
          AppTextField(
            controller: reviewController,
            textFieldType: TextFieldType.MULTILINE,
            decoration: inputDecoration(
              context,
              hint: languages.yourComment.validate().isNotEmpty ? languages.yourComment : 'Write your review (optional)',
            ),
            minLines: 3,
            maxLines: 5,
          ),
          24.height,
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
              Observer(
                builder: (_) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: appStore.isLoading
                        ? LinearGradient(
                            begin: kAppPrimaryGradient.begin,
                            end: kAppPrimaryGradient.end,
                            colors: kAppPrimaryGradientColors.map((c) => c.withValues(alpha: 0.5)).toList(),
                          )
                        : kAppPrimaryGradient,
                    borderRadius: radius(8),
                  ),
                  child: AppButton(
                    text: languages.lblSubmit,
                    elevation: 0,
                    color: Colors.transparent,
                    textStyle: boldTextStyle(color: white),
                    onTap: appStore.isLoading ? () {} : _submitRating,
                  ),
                ).expand(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
