import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/shimmer_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentHistoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.height,
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: (96 * 7) + 16,
                child: Column(
                  children: List.generate(25, (i) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? context.cardColor : null,
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? Radius.circular(12) : Radius.zero,
                          bottom: i == 24 ? Radius.circular(12) : Radius.zero,
                        ),
                      ),
                      child: Row(
                        children: List.generate(7, (index) {
                          return ShimmerWidget(
                            height: 14,
                            width: 80,
                          ).paddingRight(16);
                        }),
                      ),
                    );
                  }),
                )
              ),
            ).paddingSymmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
}
