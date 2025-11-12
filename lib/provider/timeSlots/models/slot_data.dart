import 'package:intl/intl.dart';

class SlotData {
  DateTime? date;
  List<String>? slot;

  SlotData({this.date, this.slot});

  factory SlotData.fromJson(Map<String, dynamic> json) {
    return SlotData(
      date: json['date']==null ? null : DateTime.tryParse( json['date']),
      slot: json['slots'] != null ? new List<String>.from(json['slots']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.date != null) data['date'] = DateFormat('yyyy-MM-dd').format(this.date!);
    if (this.slot != null) {
      data['slots'] = this.slot!.toSet().toList();
    }
    return data;
  }

  Map<String, dynamic> toJsonRequest() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // Always use date - date-based slots only - REQUIRED
    if(this.date != null) {
      data['date'] = DateFormat('yyyy-MM-dd').format(this.date!);
    } else {
      // Log error if date is missing
      print('ERROR: SlotData.toJsonRequest() called with null date!');
    }
    // Always include time array
    if (this.slot != null && this.slot!.isNotEmpty) {
      data['time'] = this.slot!.toSet().toList();
    } else {
      data['time'] = [];
    }
    return data;
  }
}
