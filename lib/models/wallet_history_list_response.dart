import 'dart:convert';

import 'package:handyman_provider_flutter/models/pagination_model.dart';

class WalletHistoryListResponse {
  List<WalletHistory>? data;
  Pagination? pagination;
  num? availableBalance;

  WalletHistoryListResponse({this.data, this.pagination, this.availableBalance});

  static num? _parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  factory WalletHistoryListResponse.fromJson(Map<String, dynamic> json) {
    return WalletHistoryListResponse(
      data: json['data'] != null ? (json['data'] as List).map((i) => WalletHistory.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      availableBalance: _parseNum(json['available_balance']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    data['available_balance'] = this.availableBalance;
    return data;
  }
}

class WalletHistory {
  ActivityData? activityData;
  String? activityMessage;
  String? activityType;
  String? datetime;
  int? id;
  String? userImage;
  WalletHistory({
    this.activityData,
    this.activityMessage,
    this.activityType,
    this.datetime,
    this.id,
    this.userImage,
  });

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      activityData: json['activity_data'] != null ? ActivityData.fromJson(jsonDecode(json['activity_data'] as String)) : null,
      activityMessage: json['activity_message']?.toString(),
      activityType: json['activity_type']?.toString(),
      datetime: json['datetime']?.toString(),
      id: _parseInt(json['id']),
      userImage: json['user_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (data['activity_data'] != null) {
      data['activity_data'] = this.activityData;
    }
    data['activity_message'] = this.activityMessage;
    data['activity_type'] = this.activityType;
    data['datetime'] = this.datetime;

    data['id'] = this.id;
    data['user_image'] = this.userImage;
    return data;
  }
}

class ActivityData {
  num? amount;
  num? creditDebitAmount;
  String? providerName;
  String? title;
  int? userId;
  String? transactionType;

  ActivityData({
    this.amount,
    this.providerName,
    this.title,
    this.userId,
    this.creditDebitAmount,
    this.transactionType,
  });

  static num? _parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      amount: _parseNum(json['amount']),
      providerName: json['provider_name']?.toString(),
      title: json['title']?.toString(),
      userId: _parseInt(json['user_id']),
      creditDebitAmount: _parseNum(json['credit_debit_amount']),
      transactionType: json['transaction_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['provider_name'] = this.providerName;
    data['title'] = this.title;
    data['user_id'] = this.userId;
    data['credit_debit_amount'] = this.creditDebitAmount;
    return data;
  }
}
