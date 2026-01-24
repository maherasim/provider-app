// To parse this JSON data, do
//
//     final jobRequestResponse = jobRequestResponseFromJson(jsonString);

import 'dart:convert';

import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';

JobRequestResponse jobRequestResponseFromJson( str) => JobRequestResponse.fromJson(str);

String jobRequestResponseToJson(JobRequestResponse data) => json.encode(data.toJson());

class JobRequestResponse {
  bool success;
  Data data;

  JobRequestResponse({
    required this.success,
    required this.data,
  });

  factory JobRequestResponse.fromJson(Map<String, dynamic> json) => JobRequestResponse(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  int currentPage;
  List<PostJobData> data;
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
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"] ?? 1,
    data: json["data"] != null ? List<PostJobData>.from(json["data"].map((x) => PostJobData.fromJson(x))) : <PostJobData>[],
    firstPageUrl: json["first_page_url"] ?? "",
    from: json["from"] ?? 0,
    lastPage: json["last_page"] ?? 1,
    lastPageUrl: json["last_page_url"] ?? "",
    links: json["links"] != null ? List<Link>.from(json["links"].map((x) => Link.fromJson(x))) : <Link>[],
    nextPageUrl: json["next_page_url"],
    path: json["path"] ?? "",
    perPage: json["per_page"] ?? 10,
    prevPageUrl: json["prev_page_url"],
    to: json["to"] ?? 0,
    total: json["total"] ?? 0,
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
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
