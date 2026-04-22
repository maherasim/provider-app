import 'package:handyman_provider_flutter/utils/common.dart';

class BaseResponseModel {
  String? message;
  bool? status;

  BaseResponseModel({this.message, this.status});

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      message: apiJsonValueToNullableString(json['message']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}
