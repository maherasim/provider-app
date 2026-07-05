import 'dart:async';

import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class CountdownWidget extends StatefulWidget {
  final String? text;
  final BookingDetailResponse bookingDetailResponse;

  CountdownWidget({this.text, required this.bookingDetailResponse, Key? key}) : super(key: key);

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? timer;
  bool stopTimer = true;

  int value = 0;

  @override
  void initState() {
    _startOrStopTimer(widget.bookingDetailResponse);
    LiveStream().on(LIVESTREAM_START_TIMER, (streamValue) {
      if (!mounted) return;
      final data = streamValue as Map<String, dynamic>;
      this.value = data['inSeconds'] as int;
      if (data['status'] == BookingStatusKeys.hold || data['status'] == BookingStatusKeys.complete) {
        stopTimer = true;
        timer?.cancel();
        setState(() {});
      } else {
        stopTimer = false;
        init();
      }
    });
    LiveStream().on(LIVESTREAM_PAUSE_TIMER, (streamValue) {
      if (!mounted) return;
      timer?.cancel();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStatus = widget.bookingDetailResponse.bookingDetail!.status.validate();
    final oldStatus = oldWidget.bookingDetailResponse.bookingDetail!.status.validate();
    if (newStatus != oldStatus) {
      timer?.cancel();
      _startOrStopTimer(widget.bookingDetailResponse);
    }
  }

  void _startOrStopTimer(BookingDetailResponse response) {
    if (response.bookingDetail!.status.validate() == BookingStatusKeys.inProgress) {
      value = (response.bookingDetail!.durationDiff.toInt() +
          DateTime.now()
              .difference(DateTime.parse(response.bookingDetail!.startAt.validate()))
              .inSeconds);
      stopTimer = false;
      init();
    } else {
      value = response.bookingDetail!.durationDiff.validate().toInt();
      stopTimer = true;
    }
  }

  void init() async {
    timer = Timer(1.seconds, () {
      if (!mounted) return;
      if (!stopTimer) init();
      value += 1;
      setState(() {});
    });
  }

  // Logic For Calculate Time
  String calculateTimer(int secTime) {
    int hour = 0, minute = 0, seconds = 0;

    hour = secTime ~/ 3600;

    minute = ((secTime - hour * 3600)) ~/ 60;

    seconds = secTime - (hour * 3600) - (minute * 60);

    String hourLeft = hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

    String minuteLeft = minute.toString().length < 2 ? "0" + minute.toString() : minute.toString();

    String secondsLeft = seconds.toString().length < 2 ? "0" + seconds.toString() : seconds.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void deactivate() {
    timer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    timer?.cancel();
    LiveStream().dispose(LIVESTREAM_START_TIMER);
    LiveStream().dispose(LIVESTREAM_PAUSE_TIMER);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage();
  }
}