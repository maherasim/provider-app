import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/social_icons_list.dart';

class ServiceComponent extends StatelessWidget {
  final ServiceData data;
  final double width;

  ServiceComponent({required this.data, required this.width});

  @override
  Widget build(BuildContext context) {
    // Build location as "City, Country" when available, otherwise fall back to parsed address
    String locationText = '';
    if ((data.serviceAddressMapping ?? []).isNotEmpty) {
      final mapping = (data.serviceAddressMapping ?? []).first;
      final String city = mapping.cityName.validate();
      final String country = mapping.countryName.validate();
      if (city.isNotEmpty || country.isNotEmpty) {
        locationText = [city, country].where((e) => e.isNotEmpty).join(', ');
      } else {
        final String rawAddress = mapping.providerAddressMapping?.address.validate() ?? '';
        if (rawAddress.isNotEmpty) {
          final parts = rawAddress.split(',');
          if (parts.isNotEmpty) {
            final String first = parts.first.trim();
            final String last = parts.length > 1 ? parts.last.trim() : '';
            locationText = last.isNotEmpty ? '$first -$last' : first;
          }
        }
      }
    }
    if (locationText.isEmpty) {
      locationText = '';
    }
    return AnimatedContainer(
      duration: 400.milliseconds,
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: appStore.isDarkMode ? cardDarkColor : cardColor,
      ),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 205,
            width: context.width(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CachedImageWidget(
                  url: data.imageAttachments!.isNotEmpty
                      ? data.imageAttachments!.first.validate()
                      : "",
                  fit: BoxFit.cover,
                  height: 180,
                  width: context.width(),
                ).cornerRadiusWithClipRRectOnly(
                    topRight: defaultRadius.toInt(),
                    topLeft: defaultRadius.toInt()),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    constraints:
                        BoxConstraints(maxWidth: context.width() * 0.3),
                    decoration: boxDecorationWithShadow(
                      backgroundColor: context.cardColor.withValues(alpha: 0.9),
                      borderRadius: radius(24),
                    ),
                    child: Marquee(
                      directionMarguee: DirectionMarguee.oneDirection,
                      child: Text(
                        "${data.subCategoryName.validate().isNotEmpty ? data.subCategoryName.validate() : data.categoryName.validate()}"
                            .toUpperCase(),
                        style: boldTextStyle(
                            color: appStore.isDarkMode ? white : primaryColor,
                            size: 12),
                      ).paddingSymmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                if (data.isOnlineService)
                  Positioned(
                    top: 20,
                    right: 12,
                    child: Icon(Icons.circle, color: Colors.green, size: 12),
                  ),
                Positioned(
                  bottom: 12,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: boxDecorationWithShadow(
                      backgroundColor: primaryColor,
                      borderRadius: radius(24),
                      border: Border.all(color: context.cardColor, width: 2),
                    ),
                    child: PriceWidget(
                      price: data.price.validate(),
                      isFixesService: data.isFixedService,
                      isDailyService: data.isDailyService,
                      isHourlyService: data.isHourlyService,
                      color: Colors.white,
                      hourlyTextColor: Colors.white,
                      size: 14,
                      isFreeService: data.isFreeService,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 16,
                  child: DisabledRatingBarWidget(
                      rating: data.totalRating.validate(), size: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.height,
              Marquee(
                directionMarguee: DirectionMarguee.oneDirection,
                child: Text(data.name.validate(), style: boldTextStyle())
                    .paddingSymmetric(horizontal: 16),
              ),
              5.height,
              Text(
                locationText,
                style: primaryTextStyle(size: 10),
              ).paddingSymmetric(horizontal: 16),
              5.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.totalBookingCount?.validate() ?? 0} Bookings',
                    style: primaryTextStyle(size: 10),
                  ),
                  Text(
                    'Views: ${data.views?.validate() ?? 0}',
                    style: primaryTextStyle(size: 10),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
              5.height,
              SocialIconsList(
                      mainAxisAlignment: MainAxisAlignment.start, spacing: 5)
                  .paddingSymmetric(horizontal: 16),
              16.height,
            ],
          ),
        ],
      ),
    );
  }
}
