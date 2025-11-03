import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class DisabledRatingBarWidget extends StatelessWidget {
  final num rating;
  final double? size;
  final Color? activeColor;
  final MainAxisAlignment mainAxisAlignment;

  DisabledRatingBarWidget(
      {required this.rating,
      this.size,
      this.activeColor,
      this.mainAxisAlignment = MainAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        RatingBarWidget(
          onRatingChanged: null,
          itemCount: 5,
          size: size ?? 18,
          disable: true,
          rating: rating.validate().toDouble(),
          activeColor: getRatingBarColor(rating.validate().toInt()),
        ),
        //8.width,
        //Text(rating.validate().toString(), style: primaryTextStyle(size: size)),
      ],
    );
  }
}
