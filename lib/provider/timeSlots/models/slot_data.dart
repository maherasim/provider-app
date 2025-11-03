import 'package:intl/intl.dart';

class SlotData {
  String? day;
  DateTime? date;
  List<String>? slot;

  SlotData({this.day, this.date, this.slot});

  factory SlotData.fromJson(Map<String, dynamic> json) {
    return SlotData(
      day: json['day'],
      date: json['date']==null ? null : DateTime.tryParse( json['date']),
      slot: json['slots'] != null ? new List<String>.from(json['slots']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    if(this.date != null) data['date'] = DateFormat('yyyy-MM-dd').format(this.date!);
    if (this.slot != null) {
      data['slots'] = this.slot!.toSet().toList();
    }
    return data;
  }

  Map<String, dynamic> toJsonRequest() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day?.toLowerCase();
    if(this.date != null) data['date'] = DateFormat('yyyy-MM-dd').format(this.date!);
    if (this.slot != null) {
      data['time'] = this.slot!.toSet().toList();
    }
    return data;
  }
}
