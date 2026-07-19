import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/extensions/date_formatter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/time_slots_model.dart';

class TimeSlotsList extends StatelessWidget {
  final TimeSlotModel timeSlotModel;
  const TimeSlotsList({super.key, required this.timeSlotModel});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          VerticalDivider(
            thickness: 2,
            width: 0,
          ),
          Expanded(
            child: Column(
              spacing: 4,
              children: [
                if (timeSlotModel.selectedDate.toString().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        '${languages.lblDate}:',
                        style: secondaryTextStyle(),
                      ),
                      Marquee(
                        child: Text(
                          timeSlotModel.selectedDate
                              .formatDateTime(formate: 'yyyy-MM-dd'),
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                if (timeSlotModel.startTime.validate().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${languages.lblStartTime}:',
                        style: secondaryTextStyle(),
                      ),
                      8.width,
                      Marquee(
                        child: Text(
                          timeSlotModel.startTime,
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                if (timeSlotModel.endTime.validate().isNotEmpty)
                  Row(
                    spacing: 8,
                    children: [
                      Text(
                        '${languages.lblEndTime}:',
                        style: secondaryTextStyle(),
                      ),
                      Marquee(
                        child: Text(
                          timeSlotModel.endTime,
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                if (timeSlotModel.totalHours.validate() != 0)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${languages.lblTotalHours}:',
                        style: secondaryTextStyle(),
                      ),
                      8.width,
                      Marquee(
                        child: Text(
                          timeSlotModel.totalHours.toString(),
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                if (timeSlotModel.totalDays.validate() != 0)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${languages.lblTotalDays}:',
                        style: secondaryTextStyle(),
                      ),
                      8.width,
                      Marquee(
                        child: Text(
                          timeSlotModel.totalDays.toString(),
                          style: boldTextStyle(size: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
