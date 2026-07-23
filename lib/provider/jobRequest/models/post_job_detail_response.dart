import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';

import 'bidder_data.dart';

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Single review item for provider_review (customer reviews provider) or customer_review (provider reviews customer).
class BidReviewItem {
  int? id;
  num? rating;
  String? review;
  String? raterName;
  int? raterId;
  String? createdAt;

  BidReviewItem({
    this.id,
    this.rating,
    this.review,
    this.raterName,
    this.raterId,
    this.createdAt,
  });

  factory BidReviewItem.fromJson(Map<String, dynamic> json) => BidReviewItem(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
    rating: json["rating"] is num ? json["rating"] : (json["rating"] != null ? num.tryParse(json["rating"].toString()) : null),
    review: json["review"]?.toString(),
    raterName: json["rater_name"]?.toString(),
    raterId: json["rater_id"] is int ? json["rater_id"] : int.tryParse(json["rater_id"]?.toString() ?? ''),
    createdAt: json["created_at"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "review": review,
    "rater_name": raterName,
    "rater_id": raterId,
    "created_at": createdAt,
  };
}

class PostJobDetailResponse {
  PostJobData? postRequestDetail;
  List<BidderData> bidderData;
  bool? showUpdateBid;

  PostJobDetailResponse({this.postRequestDetail, required this.bidderData, this.showUpdateBid});

  factory PostJobDetailResponse.fromJson(dynamic json) => PostJobDetailResponse(
    postRequestDetail: json['post_request_detail'] != null ? PostJobData.fromJson(json['post_request_detail']) : null,
    bidderData: json['bider_data'] == null ? [] :  List<BidderData>.from(json['bider_data'].map((e) => BidderData.fromJson(e))),
    showUpdateBid: json['show_update_bid'] ?? true,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (postRequestDetail != null) {
      map['post_request_detail'] = postRequestDetail?.toJson();
    }
      map['bider_data'] = bidderData.map((v) => v.toJson()).toList();
    if (showUpdateBid != null) {
      map['show_update_bid'] = showUpdateBid;
    }
    return map;
  }
}

class JobRequestDetailResponse {
  int? id;
  int? postRequestId;
  int? providerId;
  int? customerId;
  num? price;
  String? holdReason;
  num? advancePercent;
  String? whyChooseMe;
  num? remainingPercent;
  num? duration;
  RequestStatus status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? title;
  num? amount;
  num? quantity;
  List<ExtraChargesData> extraCharges;
  Customer? provider;
  Customer? customer;
  PostRequest? postRequest;
  String? taxPercent;
  bool? providerRatingExists;
  bool? showRateCustomerButton;
  List<BidReviewItem> providerReview;
  List<BidReviewItem> customerReview;

  JobRequestDetailResponse({
    this.id,
    this.postRequestId,
    this.providerId,
    this.customerId,
    this.price,
    this.holdReason,
    this.advancePercent,
    this.whyChooseMe,
    this.remainingPercent,
    this.duration,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.amount,
    this.quantity,
    required this.extraCharges,
    this.provider,
    this.customer,
    this.postRequest,
    this.taxPercent,
    this.providerRatingExists,
    this.showRateCustomerButton,
    this.providerReview = const [],
    this.customerReview = const [],
  });

  factory JobRequestDetailResponse.fromJson(Map<String, dynamic> json) => JobRequestDetailResponse(
    id: _toInt(json["id"]),
    postRequestId: _toInt(json["post_request_id"]),
    providerId: _toInt(json["provider_id"]),
    customerId: _toInt(json["customer_id"]),
    price: json["price"] is num ? json["price"] : num.tryParse(json["price"]?.toString() ?? ''),
    holdReason: json["hold_reason"],
    advancePercent: json["advance_percent"],
    whyChooseMe: json["why_choose_me"],
    remainingPercent: json["remaining_percent"],
    duration: json["duration"],
    status: RequestStatus.fromJson(json['status']),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    title: json["title"],
    amount: json["amount"],
    quantity: json["quantity"],
    extraCharges: json["extra_charges"] == null ? [] : extraChargesDataFromJson(json["extra_charges"]),
    provider: json["provider"] == null ? null : Customer.fromJson(json["provider"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    postRequest: json["postrequest"] == null ? null : PostRequest.fromJson(json["postrequest"]),
    taxPercent: json["tax_percent"],
    providerRatingExists: json["provider_rating_exists"] is bool ? json["provider_rating_exists"] : (json["provider_rating_exists"] == 1 || json["provider_rating_exists"] == "1"),
    showRateCustomerButton: json["show_rate_customer_button"] is bool ? json["show_rate_customer_button"] : (json["show_rate_customer_button"] != 0 && json["show_rate_customer_button"] != "0" && json["show_rate_customer_button"] != false),
    providerReview: json["provider_review"] == null ? [] : List<BidReviewItem>.from((json["provider_review"] as List).map((x) => BidReviewItem.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x as Map)))),
    customerReview: json["customer_review"] == null ? [] : List<BidReviewItem>.from((json["customer_review"] as List).map((x) => BidReviewItem.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x as Map)))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "post_request_id": postRequestId,
    "provider_id": providerId,
    "customer_id": customerId,
    "price": price,
    "hold_reason": holdReason,
    "advance_percent": advancePercent,
    "why_choose_me": whyChooseMe,
    "remaining_percent": remainingPercent,
    "duration": duration,
    "status": status.backendValue,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "title": title,
    "amount": amount,
    "quantity": quantity,
    "extra_charges": List<dynamic>.from(extraCharges.map((x) => x)),
    "provider": provider?.toJson(),
    "customer": customer?.toJson(),
    "postrequest": postRequest?.toJson(),
    "tax_percent": taxPercent,
    "provider_rating_exists": providerRatingExists,
    "show_rate_customer_button": showRateCustomerButton,
    "provider_review": providerReview.map((x) => x.toJson()).toList(),
    "customer_review": customerReview.map((x) => x.toJson()).toList(),
  };
}

List<ExtraChargesData> extraChargesDataFromJson(dynamic str) => List<ExtraChargesData>.from(str.map((x) => ExtraChargesData.fromJson(x)));

class ExtraChargesData {
  int? id;
  int? postJobBidId;
  String? title;
  num? amount;
  num? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;

  ExtraChargesData({
    this.id,
    this.postJobBidId,
    this.title,
    this.amount,
    this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory ExtraChargesData.fromJson(Map<String, dynamic> json) => ExtraChargesData(
    id: _toInt(json["id"]),
    postJobBidId: _toInt(json["post_job_bid_id"]),
    title: json["title"],
    amount: json["amount"] is num ? json["amount"] : num.tryParse(json["amount"]?.toString() ?? ''),
    quantity: json["quantity"] is num ? json["quantity"] : num.tryParse(json["quantity"]?.toString() ?? ''),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "post_job_bid_id": postJobBidId,
    "title": title,
    "amount": amount,
    "quantity": quantity,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}


class Customer {
  int? id;
  String? displayName;

  Customer({
    this.id,
    this.displayName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: _toInt(json["id"]),
    displayName: json["display_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "display_name": displayName,
  };
}

class PostRequest {
  int? id;
  String? title;
  int? customerId;
  RequestStatus status;
  num? providerId;
  num? remainingPercent;
  JobType type;
  DateTime? startDate;
  DateTime? endDate;
  int? totalBudget;
  int? cityId;
  int? countryId;
  String? jobPrice;
  String? streetAddress;
  String? houseNumber;
  String? workingAddress;
  int? totalHours;
  PriceType priceType;
  int? totalDays;
  City? city;
  City? country;
  List<PostBidList> postBidList;

  PostRequest({
    this.id,
    this.title,
    this.customerId,
    required this.status,
    this.providerId,
    this.remainingPercent,
    required this.type,
    this.startDate,
    this.endDate,
    this.totalBudget,
    this.cityId,
    this.countryId,
    this.jobPrice,
    this.streetAddress,
    this.houseNumber,
    this.workingAddress,
    this.totalHours,
    required this.priceType,
    this.totalDays,
    this.city,
    this.country,
    required this.postBidList,
  });

  factory PostRequest.fromJson(Map<String, dynamic> json) => PostRequest(
    id: _toInt(json["id"]),
    title: json["title"],
    customerId: _toInt(json["customer_id"]),
    status: RequestStatus.fromJson(json['status']),
    providerId: json["provider_id"],
    remainingPercent: json["remaining_percent"],
    type: JobType.values.firstWhere((e) => e.backendValue == json['type'],orElse:() => JobType.onSite),
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    totalBudget: _toInt(json["total_budget"]),
    cityId: _toInt(json["city_id"]),
    countryId: _toInt(json["country_id"]),
    jobPrice: json["job_price"],
    streetAddress: json["street_address"],
    houseNumber: json["house_number"],
    workingAddress: json["working_address"],
    totalHours: _toInt(json["total_hours"]),
    priceType: PriceType.values.firstWhere((e) => e.backendValue == json['price_type'],orElse:() => PriceType.fixed),
    totalDays: _toInt(json["total_days"]),
    city: json["city"] == null ? null : City.fromJson(json["city"]),
    country: json["country"] == null ? null : City.fromJson(json["country"]),
    postBidList: json["post_bid_list"] == null ? [] : List<PostBidList>.from(json["post_bid_list"]!.map((x) => PostBidList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "customer_id": customerId,
    "status": status.backendValue,
    "provider_id": providerId,
    "remaining_percent": remainingPercent,
    "type": type,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "total_budget": totalBudget,
    "city_id": cityId,
    "country_id": countryId,
    "job_price": jobPrice,
    "street_address": streetAddress,
    "house_number": houseNumber,
    "working_address": workingAddress,
    "total_hours": totalHours,
    "price_type": priceType.backendValue,
    "total_days": totalDays,
    "city": city?.toJson(),
    "country": country?.toJson(),
    "post_bid_list": List<dynamic>.from(postBidList.map((x) => x.toJson())),
  };
}
class City {
  int? id;
  String? name;

  City({
    this.id,
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: _toInt(json["id"]),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class PostBidList {
  int? id;
  int? postRequestId;

  PostBidList({
    this.id,
    this.postRequestId,
  });

  factory PostBidList.fromJson(Map<String, dynamic> json) => PostBidList(
    id: _toInt(json["id"]),
    postRequestId: _toInt(json["post_request_id"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "post_request_id": postRequestId,
  };
}
