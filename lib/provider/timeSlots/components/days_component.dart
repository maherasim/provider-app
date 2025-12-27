import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:intl/intl.dart';
import 'package:mp_month_picker/mp_month_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class DaysComponent extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDayChanged;
  final Function()? onEditTap;

  DaysComponent({ this.initialDate, this.onDayChanged, super.key, this.onEditTap});

  @override
  DaysComponentState createState() => DaysComponentState();
}

class DaysComponentState extends State<DaysComponent> {
  int selectedDayIndex = 0;

  var dateScrollController = ScrollController();

  DateTime selectedDate = DateTime.now();

  List<DateTime> currentMonthDates = [];

  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedDate = widget.initialDate ?? DateTime.now();
    currentMonth = selectedDate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await setCurrentMonthDates(autoScroll: widget.initialDate != null);
      setState(() {});
    });

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
      lastDate: DateTime(DateTime.now().year, 12),
      selectedMonthColor: context.primaryColor,
      unselectedMonthColor:  appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      monthTextStyle: TextStyle(color: appStore.isDarkMode ? white : appTextPrimaryColor),
      backgroundColor: context.cardColor,
      headerBgColor: context.primaryColor,
      transitionDuration: Duration(milliseconds: 300),
      cancelTxtStyle: TextStyle(color: context.primaryColor),
      doneTxtStyle: TextStyle(color: context.primaryColor,),
      selectedMonthBorderRadius: BorderRadius.circular(16),
    );
    if(date == null) return;

    if (date.month == DateTime.now().month) {
      currentMonth = DateTime.now();
      onDateChange(currentMonth);
    } else {
      currentMonth = date;
      onDateChange(currentMonth);
    }

    await setCurrentMonthDates();
  }

  setCurrentMonthDates({bool autoScroll = false})  async {
    currentMonthDates.clear();
    int totalDays = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    currentMonthDates.addAll(List.generate(totalDays, (index) => DateTime(currentMonth.year, currentMonth.month, index + 1)));
    currentMonthDates.removeWhere((e) => e.isBefore(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)));
    if(autoScroll) {
      currentMonth = selectedDate;
      setState(() {});
      double totalWithDays = (currentMonthDates.indexOf(currentMonth) * 60);
      double totalDeviceWithPadding = ((MediaQuery.of(context).size.width / 2) + 16);
      double total = 0;
      if (totalWithDays > totalDeviceWithPadding) {
        total = totalWithDays - totalDeviceWithPadding;
      }
      print(total);
      print("total");

      await dateScrollController.animateTo(total, duration: 2.seconds, curve: Curves.ease);
    } else {
      await dateScrollController.animateTo(0, duration: 2.seconds, curve: Curves.ease);
    }
  }

  onArrowTap({bool isForward = true}) async {
    if(isForward) {
      currentMonth = currentMonth.month == 12 ? DateTime(currentMonth.year+1,1) :  DateTime(currentMonth.year, currentMonth.month+1);
    } else {
      if(currentMonth.year == DateTime.now().year && currentMonth.month == DateTime.now().month){
        return;
      }else {
        currentMonth = currentMonth.month == 1 ? DateTime(currentMonth.year-1,12) :  DateTime(currentMonth.year, currentMonth.month-1);
      }
    }
    await setCurrentMonthDates();
    onDateChange(currentMonthDates.first);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', appStore.selectedLanguageCode).format(currentMonth),
                    style: boldTextStyle(),
                  ),
                  16.width,
                  // Left Arrow Button
                  if(!(currentMonth.year == DateTime.now().year && currentMonth.month == DateTime.now().month))
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onArrowTap(isForward: false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 36,
                          width: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: kAppPrimaryGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: gradientRed.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).paddingOnly(right: 8),
                  // Right Arrow Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onArrowTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: kAppPrimaryGradient,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: gradientRed.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if(widget.onEditTap != null) IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: widget.onEditTap,
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 8),
          HorizontalList(
            controller: dateScrollController,
            itemCount: currentMonthDates.length,
            crossAxisAlignment: WrapCrossAlignment.start,
            wrapAlignment: WrapAlignment.start,
            runSpacing: 8,
            spacing: 8,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemBuilder: (BuildContext context, int index) {
              DateTime data = currentMonthDates[index];
              final isSelected = data.day == selectedDate.day && data.month == selectedDate.month && data.year == selectedDate.year;
              return Container(
                height: 60,
                width: 50,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: kAppPrimaryGradient,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      )
                    : boxDecorationWithRoundedCorners(
                        backgroundColor: appStore.isDarkMode
                            ? scaffoldDarkColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EE', appStore.selectedLanguageCode).format(data).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldTextStyle(
                        color: selectedDayIndex == index ? white : appStore.isDarkMode ? white : appTextPrimaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('dd', appStore.selectedLanguageCode).format(data),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldTextStyle(
                        color: selectedDayIndex == index ? white : appStore.isDarkMode ? white : appTextPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ).onTap(() => onDateChange(data));
            },
          ),
        ],
      ),
    );

  }
}
