import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/available_slots_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/days_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class EditTimeSlotScreen extends StatefulWidget {
  final List<SlotData> slotData;
  final DateTime? selectedDay;
  final Function(List<SlotData>) onSave;

  EditTimeSlotScreen({required this.slotData, this.selectedDay, required this.onSave});

  @override
  EditTimeSlotScreenState createState() => EditTimeSlotScreenState();
}

class EditTimeSlotScreenState extends State<EditTimeSlotScreen> {
  UniqueKey keyForTimeSlotWidget = UniqueKey();
  int selectedDayIndex = 0;

  List<String> selectedTimeSlots = [];

  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedDay = widget.selectedDay ?? DateTime.now();
    // Initialize selectedTimeSlots with the current day's slots (remove duplicates)
    List<String> daySlots = widget.slotData.firstWhere(
      (element) => element.date?.year == selectedDay.year && 
                   element.date?.month == selectedDay.month && 
                   element.date?.day == selectedDay.day,
      orElse: () => SlotData(slot: []),
    ).slot.validate();
    // Remove duplicates and create a fresh copy
    selectedTimeSlots = daySlots.toSet().toList();
    setState(() {});
  }

  Future saveTimeSlot() async {
    timeSlotStore.serviceSlotData = widget.slotData;
    finish(context, true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.timeSlots,
        center: true,
        textColor: white,
        color: context.primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DaysComponent(
                  initialDate: selectedDay,
                  onDayChanged: (day) {
                    selectedDay = day;
                    // Reset selectedTimeSlots to the current day's slots when day changes (remove duplicates)
                    List<String> daySlots = widget.slotData.firstWhere(
                      (element) => element.date?.year == day.year && 
                                   element.date?.month == day.month && 
                                   element.date?.day == day.day,
                      orElse: () => SlotData(slot: []),
                    ).slot.validate();
                    // Remove duplicates and create a fresh copy
                    selectedTimeSlots = daySlots.toSet().toList();
                    keyForTimeSlotWidget = UniqueKey();
                    setState(() {});
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.chooseTime, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                    // TextButton(
                    //   child: Text(languages.copyTo, style: secondaryTextStyle()),
                    //   onPressed: () async {
                    //     List<String> list = await showModalBottomSheet(
                    //       backgroundColor: Colors.transparent,
                    //       context: context,
                    //       isScrollControlled: true,
                    //       isDismissible: true,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
                    //       ),
                    //       builder: (_) {
                    //         return DaysBottomSheet(selectedDay: selectedDay);
                    //       },
                    //     );
                    //
                    //     list.forEach((element) {
                    //       widget.slotData.removeWhere((e) => e.day.validate().toLowerCase() == element.toLowerCase());
                    //       widget.slotData.add(SlotData(day: element.toLowerCase(), slot: selectedTimeSlots.toSet().toList()));
                    //     });
                    //
                    //     keyForTimeSlotWidget = UniqueKey();
                    //
                    //     setState(() {});
                    //   },
                    // ),
                  ],
                ).paddingOnly(left: 16, right: 16, top: 16),
                AvailableSlotsComponent(
                  key: keyForTimeSlotWidget,
                  onChanged: (List<String> selectedSlots) {
                    selectedTimeSlots = selectedSlots;
                    setState(() {});
                  },
                  availableSlots: [],
                  selectedSlots: widget.slotData.firstWhere((element) =>  element.date?.year == selectedDay.year && element.date?.month == selectedDay.month && element.date?.day == selectedDay.day, orElse: () => SlotData(slot: [])).slot.validate(),
                ).paddingSymmetric(horizontal: 16, vertical: 16),
              ],
            ),
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: AppButton(
        width: context.width(),
        color: primaryColor,
        text: languages.lblUpdate,
        onTap: () {
          // Remove existing slot for the selected day
          widget.slotData.removeWhere((element) => 
            element.date?.year == selectedDay.year && 
            element.date?.month == selectedDay.month && 
            element.date?.day == selectedDay.day
          );
          
          // Add new slot data only if there are selected time slots
          if (selectedTimeSlots.isNotEmpty) {
            // Remove duplicates and ensure clean list
            List<String> cleanSlots = selectedTimeSlots.toSet().toList();
            // Create date at midnight to ensure consistent date format
            DateTime slotDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            log('Creating SlotData with date: $slotDate, slots: $cleanSlots');
            SlotData newSlot = SlotData(
              date: slotDate, 
              slot: cleanSlots
            );
            log('Created SlotData - date: ${newSlot.date}, slot: ${newSlot.slot}');
            widget.slotData.add(newSlot);
          }
          
          // Sort by date
          widget.slotData.sort((a,b) => a.date!.compareTo(b.date!));
          
          // Debug: Log all slots before sending
          log('All slots before sending:');
          for (var slot in widget.slotData) {
            log('  - date: ${slot.date}, slots: ${slot.slot}');
            if (slot.date != null) {
              log('    toJsonRequest: ${slot.toJsonRequest()}');
            }
          }
          
          // Call onSave with updated slot data
          widget.onSave.call(widget.slotData);
          setState((){});
        },
      ).paddingAll(24),
    );
  }
}
