class HandymanServicePaymentModel {
  int? id;
  String? bookingId;
  String? servicePostJob;
  HandymanServicePaymentUser? user;
  String? paymentType;
  String? paymentStatus;
  String? statusLabel;
  String? datetime;
  String? datetimeRaw;
  num? myEarning;
  String? myEarningFormatted;
  num? totalAmount;
  String? totalAmountFormatted;

  HandymanServicePaymentModel({
    this.id,
    this.bookingId,
    this.servicePostJob,
    this.user,
    this.paymentType,
    this.paymentStatus,
    this.statusLabel,
    this.datetime,
    this.datetimeRaw,
    this.myEarning,
    this.myEarningFormatted,
    this.totalAmount,
    this.totalAmountFormatted,
  });

  factory HandymanServicePaymentModel.fromJson(Map<String, dynamic> json) {
    return HandymanServicePaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      servicePostJob: json['service_post_job'],
      user: json['user'] != null ? HandymanServicePaymentUser.fromJson(json['user']) : null,
      paymentType: json['payment_type'],
      paymentStatus: json['payment_status'],
      statusLabel: json['status_label'],
      datetime: json['datetime'],
      datetimeRaw: json['datetime_raw'],
      myEarning: json['my_earning'],
      myEarningFormatted: json['my_earning_formatted'],
      totalAmount: json['total_amount'],
      totalAmountFormatted: json['total_amount_formatted'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['service_post_job'] = servicePostJob;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['payment_type'] = paymentType;
    data['payment_status'] = paymentStatus;
    data['status_label'] = statusLabel;
    data['datetime'] = datetime;
    data['datetime_raw'] = datetimeRaw;
    data['my_earning'] = myEarning;
    data['my_earning_formatted'] = myEarningFormatted;
    data['total_amount'] = totalAmount;
    data['total_amount_formatted'] = totalAmountFormatted;
    return data;
  }
}

class HandymanServicePaymentUser {
  int? id;
  String? name;
  String? profileImage;
  String? address;

  HandymanServicePaymentUser({
    this.id,
    this.name,
    this.profileImage,
    this.address,
  });

  factory HandymanServicePaymentUser.fromJson(Map<String, dynamic> json) {
    return HandymanServicePaymentUser(
      id: json['id'],
      name: json['name'],
      profileImage: json['profile_image'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile_image'] = profileImage;
    data['address'] = address;
    return data;
  }
}

class HandymanServicePaymentResponse {
  HandymanServicePaymentPagination? pagination;
  List<HandymanServicePaymentModel>? data;

  HandymanServicePaymentResponse({
    this.pagination,
    this.data,
  });

  factory HandymanServicePaymentResponse.fromJson(Map<String, dynamic> json) {
    return HandymanServicePaymentResponse(
      pagination: json['pagination'] != null
          ? HandymanServicePaymentPagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => HandymanServicePaymentModel.fromJson(e)).toList()
          : null,
    );
  }
}

class HandymanServicePaymentPagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;
  int? from;
  int? to;
  String? nextPageUrl;
  String? previousPageUrl;

  HandymanServicePaymentPagination({
    this.totalItems,
    this.perPage,
    this.currentPage,
    this.totalPages,
    this.from,
    this.to,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory HandymanServicePaymentPagination.fromJson(Map<String, dynamic> json) {
    return HandymanServicePaymentPagination(
      totalItems: json['total_items'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      from: json['from'],
      to: json['to'],
      nextPageUrl: json['next_page_url'],
      previousPageUrl: json['previous_page_url'],
    );
  }
}
