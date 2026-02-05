import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/pagination_model.dart';
import 'package:handyman_provider_flutter/models/tax_list_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';

import 'package_response.dart';
import 'extra_charges_model.dart';

class PaymentListResponse {
  Pagination? pagination;
  List<PaymentData>? data;

  PaymentListResponse({this.pagination, this.data});

  PaymentListResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List).map((i) => PaymentData.fromJson(i)).toList();
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentData {
  int? id;
  int? bookingId;
  int? customerId;
  num? totalAmount;
  String? paymentStatus;
  String? paymentMethod;
  String? customerName;
  String? txnId;
  int? quantity;
  CouponData? couponData;
  List<TaxData>? taxes;
  num? discount;
  num? price;
  List<ExtraChargesModel>? extraCharges;
  PackageData? packageData;

  String? date;
  DateTime? dateTime;
  String? paymentType;
  String? status;
  BookingData? booking;
  UserData? customer;

  bool get isPackageBooking => packageData != null ? true : false;

  PaymentData({
    this.id,
    this.bookingId,
    this.customerId,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.customerName,
    this.quantity,
    this.couponData,
    this.taxes,
    this.discount,
    this.price,
    this.extraCharges,
    this.date,
    this.txnId,
    this.packageData,
    this.dateTime,
    this.paymentType,
    this.status,
    this.booking,
    this.customer,
  });

  PaymentData.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null);
    bookingId = json['booking_id'] is int ? json['booking_id'] : (json['booking_id'] != null ? int.tryParse(json['booking_id'].toString()) : null);
    customerId = json['customer_id'] is int ? json['customer_id'] : (json['customer_id'] != null ? int.tryParse(json['customer_id'].toString()) : null);
    totalAmount = json['total_amount'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    customerName = json['customer_name'];
    quantity = json['quantity'] is int ? json['quantity'] : (json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : null);
    txnId = json['txn_id'];
    taxes = json['taxes'] != null ? (json['taxes'] as List).map((i) => TaxData.fromJson(i)).toList() : null;
    couponData = json['coupon_data'] != null ? CouponData.fromJson(json['coupon_data']) : null;
    packageData = json['booking_package'] != null ? PackageData.fromJson(json['booking_package']) : null;
    discount = json['discount'];
    price = json['price'];
    date = json['date'];
    extraCharges = json['extra_charges'] != null ? (json['extra_charges'] as List).map((i) => ExtraChargesModel.fromJson(i)).toList() : null;
    if (json['datetime'] != null) {
      try {
    print(json['datetime'].toString().split(' ').first);
        dateTime = DateTime.parse(json['datetime']);
      } catch (e) {
        dateTime = null;
      }
    } else {
      dateTime = null;
    }
    paymentType = json['payment_type'];
    status = json['status'];
    booking = json['booking'] != null ? BookingData.fromJson(json['booking']) : null;
    customer = json['customer'] != null ? UserData.fromJson(json['customer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['customer_id'] = this.customerId;
    data['total_amount'] = this.totalAmount;
    data['payment_status'] = this.paymentStatus;
    data['payment_method'] = this.paymentMethod;
    data['customer_name'] = this.customerName;
    data['quantity'] = this.quantity;
    data['discount'] = this.discount;
    data['price'] = this.price;
    data['date'] = this.date;
    data['txn_id'] = this.txnId;
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    if (this.packageData != null) {
      data['booking_package'] = this.packageData!.toJson();
    }
    if (this.extraCharges != null) {
      data['extra_charges'] = this.extraCharges!.map((v) => v.toJson()).toList();
    }
    if (this.dateTime != null) {
      data['datetime'] = this.dateTime!.toIso8601String();
    }
    data['payment_type'] = this.paymentType;
    data['status'] = this.status;
    if (this.booking != null) {
      data['booking'] = this.booking!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}
