

import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/models/post_job_payment_data.dart';

PaymentHistoryResponse paymentHistoryResponseFromJson( str) => PaymentHistoryResponse.fromJson(str);

class PaymentHistoryResponse {
  bool status;
  PaymentHistoryData data;

  PaymentHistoryResponse({
    required this.status,
    required this.data,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) => PaymentHistoryResponse(
    status: json["status"] is bool ? json["status"] : (json["status"] == true || json["status"] == 1),
    data: json["data"] != null ? PaymentHistoryData.fromJson(json["data"]) : PaymentHistoryData(
      payments: Data(
        currentPage: 1,
        data: [],
        firstPageUrl: "",
        from: 0,
        lastPage: 1,
        lastPageUrl: "",
        links: [],
        nextPageUrl: null,
        path: "",
        perPage: 20,
        prevPageUrl: null,
        to: 0,
        total: 0,
        postJobData: null,
      ),
      postJobPayments: Data(
        currentPage: 1,
        data: [],
        firstPageUrl: "",
        from: 0,
        lastPage: 1,
        lastPageUrl: "",
        links: [],
        nextPageUrl: null,
        path: "",
        perPage: 20,
        prevPageUrl: null,
        to: 0,
        total: 0,
        postJobData: null,
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class PaymentHistoryData {
  Data payments;
  Data postJobPayments;

  PaymentHistoryData({
    required this.payments,
    required this.postJobPayments,
  });

  factory PaymentHistoryData.fromJson(Map<String, dynamic> json) => PaymentHistoryData(
    payments: json["payments"] != null ? Data.fromJson(json["payments"], isPostJobPayment: false) : Data(
      currentPage: 1,
      data: [],
      firstPageUrl: "",
      from: 0,
      lastPage: 1,
      lastPageUrl: "",
      links: [],
      nextPageUrl: null,
      path: "",
      perPage: 20,
      prevPageUrl: null,
      to: 0,
      total: 0,
      postJobData: null,
    ),
    postJobPayments: json["post_job_payments"] != null ? Data.fromJson(json["post_job_payments"], isPostJobPayment: true) : Data(
      currentPage: 1,
      data: [],
      firstPageUrl: "",
      from: 0,
      lastPage: 1,
      lastPageUrl: "",
      links: [],
      nextPageUrl: null,
      path: "",
      perPage: 20,
      prevPageUrl: null,
      to: 0,
      total: 0,
      postJobData: null,
    ),
  );

  Map<String, dynamic> toJson() => {
    "payments": payments.toJson(),
    "post_job_payments": postJobPayments.toJson(),
  };
}

class Data {
  int currentPage;
  List<PaymentData> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;
  List<PostJobPaymentData>? postJobData; // For post_job_payments

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
    this.postJobData,
  });

  factory Data.fromJson(Map<String, dynamic> json, {bool isPostJobPayment = false}) => Data(
    currentPage: json["current_page"] is int ? json["current_page"] : (json["current_page"] != null ? int.tryParse(json["current_page"].toString()) ?? 1 : 1),
    data: isPostJobPayment ? [] : (json["data"] != null && json["data"] is List ? List<PaymentData>.from(json["data"].map((x) => PaymentData.fromJson(x))) : []),
    firstPageUrl: json["first_page_url"] ?? "",
    from: json["from"] is int ? json["from"] : (json["from"] != null ? int.tryParse(json["from"].toString()) ?? 0 : 0),
    lastPage: json["last_page"] is int ? json["last_page"] : (json["last_page"] != null ? int.tryParse(json["last_page"].toString()) ?? 1 : 1),
    lastPageUrl: json["last_page_url"] ?? "",
    links: json["links"] != null && json["links"] is List ? List<Link>.from(json["links"].map((x) => Link.fromJson(x))) : [],
    nextPageUrl: json["next_page_url"],
    path: json["path"] ?? "",
    perPage: json["per_page"] is int ? json["per_page"] : (json["per_page"] != null ? int.tryParse(json["per_page"].toString()) ?? 20 : 20),
    prevPageUrl: json["prev_page_url"],
    to: json["to"] is int ? json["to"] : (json["to"] != null ? int.tryParse(json["to"].toString()) ?? 0 : 0),
    total: json["total"] is int ? json["total"] : (json["total"] != null ? int.tryParse(json["total"].toString()) ?? 0 : 0),
    postJobData: isPostJobPayment ? (json["data"] != null && json["data"] is List ? List<PostJobPaymentData>.from(json["data"].map((x) => PostJobPaymentData.fromJson(x))) : []) : null,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
    if (postJobData != null) "post_job_data": List<dynamic>.from(postJobData!.map((x) => x.toJson())),
  };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"] ?? "",
    active: json["active"] is bool ? json["active"] : (json["active"] == true || json["active"] == 1),
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}



