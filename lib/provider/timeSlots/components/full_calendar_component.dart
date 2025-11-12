import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:intl/intl.dart';
import 'package:mp_month_picker/mp_month_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class FullCalendarComponent extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDayChanged;
  final Function()? onEditTap;
  final List<SlotData>? slotData; // Optional: to show which days have slots

  FullCalendarComponent({
    this.initialDate,
    this.onDayChanged,
    super.key,
    this.onEditTap,
    this.slotData,
  });

  @override
  FullCalendarComponentState createState() => FullCalendarComponentState();
}

class FullCalendarComponentState extends State<FullCalendarComponent> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  List<List<DateTime?>> calendarDays = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedDate = widget.initialDate ?? DateTime.now();
    currentMonth = selectedDate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      buildCalendar();
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void buildCalendar() {
    calendarDays.clear();
    
    // Get first day of month and last day
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    DateTime lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    // Adjust to show Monday as first day (German style)
    int firstDayWeekday = firstDay.weekday; // Monday = 1, Sunday = 7
    
    // Create calendar grid
    List<DateTime?> week = [];
    
    // Add previous month's days before the first day
    if (firstDayWeekday > 1) {
      DateTime prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 0);
      int daysInPrevMonth = prevMonth.day;
      for (int i = firstDayWeekday - 2; i >= 0; i--) {
        DateTime prevDate = DateTime(currentMonth.year, currentMonth.month - 1, daysInPrevMonth - i);
        week.add(prevDate);
      }
    }
    
    // Add all days of the current month
    for (int day = 1; day <= lastDay.day; day++) {
      DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
      week.add(date);
      
      // Start new week if we've reached Sunday (7 days)
      if (week.length == 7) {
        calendarDays.add(List.from(week));
        week.clear();
      }
    }
    
    // Add next month's days to fill the last week
    int remainingDays = 7 - week.length;
    for (int day = 1; day <= remainingDays; day++) {
      DateTime nextDate = DateTime(currentMonth.year, currentMonth.month + 1, day);
      week.add(nextDate);
    }
    if (week.isNotEmpty) {
      calendarDays.add(week);
    }
  }

  Future<void> onDateChange(DateTime date) async {
    selectedDate = date;
    widget.onDayChanged?.call(selectedDate);
    setState(() {});
  }

  onMonthTap() async {
    DateTime? date = await showMpMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1, 12),
      selectedMonthColor: context.primaryColor,
      unselectedMonthColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      monthTextStyle: TextStyle(color: appStore.isDarkMode ? white : appTextPrimaryColor),
      backgroundColor: context.cardColor,
      headerBgColor: context.primaryColor,
      transitionDuration: Duration(milliseconds: 300),
      cancelTxtStyle: TextStyle(color: context.primaryColor),
      doneTxtStyle: TextStyle(color: context.primaryColor),
      selectedMonthBorderRadius: BorderRadius.circular(16),
    );
    if (date == null) return;

    currentMonth = date;
    buildCalendar();
    onDateChange(DateTime(currentMonth.year, currentMonth.month, 1));
  }

  onArrowTap({bool isForward = true}) async {
    if (isForward) {
      currentMonth = currentMonth.month == 12
          ? DateTime(currentMonth.year + 1, 1)
          : DateTime(currentMonth.year, currentMonth.month + 1);
    } else {
      if (currentMonth.year == DateTime.now().year &&
          currentMonth.month == DateTime.now().month) {
        return;
      } else {
        currentMonth = currentMonth.month == 1
            ? DateTime(currentMonth.year - 1, 12)
            : DateTime(currentMonth.year, currentMonth.month - 1);
      }
    }
    buildCalendar();
    setState(() {});
  }

  bool hasSlots(DateTime date) {
    if (widget.slotData == null) return false;
    return widget.slotData!.any((slot) =>
        slot.date?.year == date.year &&
        slot.date?.month == date.month &&
        slot.date?.day == date.day &&
        slot.slot != null &&
        slot.slot!.isNotEmpty);
  }

  bool isPastDate(DateTime date) {
    return date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with month/year and navigation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Arrow Button
                if (!(currentMonth.year == DateTime.now().year &&
                    currentMonth.month == DateTime.now().month))
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onArrowTap(isForward: false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.chevron_left,
                          size: 22,
                          color: appStore.isDarkMode ? Colors.white70 : appTextPrimaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(width: 38),
                
                // Month/Year - clickable to open month picker
                Expanded(
                  child: GestureDetector(
                    onTap: onMonthTap,
                    child: Text(
                      DateFormat('MMMM yyyy', appStore.selectedLanguageCode).format(currentMonth),
                      style: boldTextStyle(size: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Right Arrow Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onArrowTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: appStore.isDarkMode ? Colors.white70 : appTextPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Week day headers (Monday first)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: List.generate(7, (index) {
                // Get weekday name (Monday = 1, Sunday = 7)
                int weekday = index + 1; // 1-7
                String dayName = DateFormat('E', appStore.selectedLanguageCode)
                    .format(DateTime(2024, 1, weekday)); // Use a reference date
                return Expanded(
                  child: Center(
                    child: Text(
                      dayName.substring(0, 2).toUpperCase(), // First 2 letters
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Divider(height: 1, thickness: 0.5),
          
          // Calendar grid
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              children: calendarDays.map((week) {
                return Row(
                  children: week.map((date) {
                    return Expanded(
                      child: _buildDayCell(date),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          
          // Footer with selected date
          Divider(height: 1, thickness: 0.5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d. MMMM yyyy', appStore.selectedLanguageCode).format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: appStore.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.onEditTap != null) ...[
                  12.width,
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onEditTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) {
      return Container(
        height: 48,
        margin: EdgeInsets.all(4),
        child: SizedBox(),
      );
    }

    final isSelected = date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;
    final isPast = isPastDate(date);
    final hasSlot = hasSlots(date);
    
    // Check if date is from previous or next month
    final isCurrentMonth = date.month == currentMonth.month && date.year == currentMonth.year;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPast ? null : () => onDateChange(date),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : hasSlot && isCurrentMonth && !isPast
                    ? Colors.green
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !isSelected && !hasSlot
                ? Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected || (hasSlot && isCurrentMonth && !isPast)
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : hasSlot && isCurrentMonth && !isPast
                        ? Colors.white
                        : !isCurrentMonth
                            ? (appStore.isDarkMode ? Colors.grey[700] : Colors.grey[400])
                            : isPast
                                ? (appStore.isDarkMode ? Colors.grey[600] : Colors.grey[400])
                                : (appStore.isDarkMode ? Colors.white : appTextPrimaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add this import if SlotData is not accessible
// import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';

