import 'dart:ui';
import 'dart:developer' as developer;

import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';

import '../../../models/service_model.dart';

class PostJobData {

  String? reason;
  num? providerId;
  num? customerId;
  String? customerProfile;
  bool? canBid;
  List<ServiceData>? service;
  String? createdAt;

  num? price;
  num? id;
  String? title;
  String? description;
  int? categoryId;
  int? subCategoryId;
  int? countryId;
  int? stateId;
  int? cityId;
  String? startDate;
  String? endDate;
  num? totalDays;
  num? totalHours;
  String? requirement;
  double? latitude;
  double? longitude;

  PriceType? priceType;
  JobType? type;
  JobSchedule? jobSchedule;
  RemoteWorkLevel? remoteWorkLevel;
  CareerLevel? careerLevel;
  EducationLevel? educationLevel;
  TravelRequirement? travelRequired;
  String? streetAddress;
  String? houseNumber;
  String? workingAddress;
  String? duties;
  String? benefits;
  num? totalBudget;

  RequestStatus status;

  String? customerName;


  String? date;
  String? image;
  DateTime? updatedAt;
  // UserData? customer;
  Category? category;


  List<String> images;
  String? jobPrice;
  int? acceptedBidId;

  num? totalViews;

  num? advancePercent;
  num? remainingPercent;

  num? proposalsCount;
  String? countryName;
  String? stateName;
  String? cityName;

  PostJobData({
    this.id,
    this.title,
    this.description,
    this.reason,
    this.price,
    this.providerId,
    this.customerId,
    this.customerProfile,
    required this.status,
    this.canBid,
    this.service,
    this.createdAt,
    this.categoryId,
    this.subCategoryId,
    this.countryId,
    this.stateId,
    this.cityId,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.totalHours,
    this.requirement,
    this.latitude,
    this.longitude,
    this.priceType,
    this.jobSchedule,
    this.remoteWorkLevel,
    this.careerLevel,
    this.travelRequired,
    this.educationLevel,
    this.streetAddress,
    this.houseNumber,
    this.workingAddress,
    this.duties,
    this.benefits,
    this.totalBudget,

    this.type,

    this.customerName,

    this.date,
    this.image,
    this.updatedAt,
    // this.customer,
    this.category,


    required this.images,
    this.jobPrice,
    this.acceptedBidId,
    this.totalViews,
    this.advancePercent,
    this.remainingPercent,
    this.proposalsCount,
    this.countryName,
    this.stateName,
    this.cityName,
  });

  factory PostJobData.fromJson(Map<String, dynamic> json) => PostJobData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    reason: json["reason"],
    price: json["price"],
    providerId: json["provider_id"],
    customerId: json["customer_id"],
    customerProfile: json["customer_profile"],
    canBid: json["can_bid"],
    service: json["service"] == null ? [] : List<ServiceData>.from(json["service"]!.map((x) => ServiceData.fromJson(x))),
    createdAt: json["created_at"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    startDate: json["start_date"],
    endDate: json["end_date"],
    totalDays: json["total_days"],
    totalHours: json["total_hours"],
    requirement: json["requirement"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    status: RequestStatus.fromJson(json["status"]),
    priceType: (json["price_type"] ?? json["job_price"]) == null ? null : PriceType.values.firstWhere((e) => e.backendValue == (json["price_type"] ?? json["job_price"]), orElse: () => PriceType.fixed),
    type: json["type"] == null ? null : JobType.values.firstWhere((e) => e.backendValue == json["type"], orElse: () => JobType.onSite),
    jobSchedule: json["job_schedule"] == null ? null : JobSchedule.values.firstWhere((e) => e.backendValue == json["job_schedule"], orElse: () => JobSchedule.fullTime),
    remoteWorkLevel: json["remote_work_level"] == null ? null : RemoteWorkLevel.values.firstWhere((e) => e.backendValue == json["remote_work_level"], orElse: () => RemoteWorkLevel.onsite0),
    careerLevel: json["career_level"] == null ? null : CareerLevel.values.firstWhere((e) => e.backendValue == json["career_level"], orElse: () => CareerLevel.notSpecified),
    educationLevel: json["education_level"] == null ? null : EducationLevel.values.firstWhere((e) => e.backendValue == json["education_level"], orElse: () => EducationLevel.notSpecified),
    travelRequired: () {
      if (json["travel_required"] == null) return null;
      final rawValue = json["travel_required"];
      final stringValue = rawValue.toString().trim();
      developer.log('Parsing travel_required - Raw: $rawValue, String: $stringValue');
      
      // Direct comparison with enum backend values
      if (stringValue == "1" || stringValue == "yes") {
        developer.log('Travel Required: YES');
        return TravelRequirement.yes;
      } else if (stringValue == "0" || stringValue == "no") {
        developer.log('Travel Required: NO');
        return TravelRequirement.no;
      }
      
      // Try to find in enum
      try {
        final result = TravelRequirement.values.firstWhere(
          (e) => e.backendValue == stringValue,
        );
        developer.log('Travel Required found in enum: ${result.displayName}');
        return result;
      } catch (e) {
        developer.log('Travel Required not found in enum, defaulting to NO');
        return TravelRequirement.no;
      }
    }(),
    streetAddress: json["street_address"],
    houseNumber: json["house_number"],
    workingAddress: json["working_address"],
    duties: json["duties"],
    benefits: json["benefits"],
    totalBudget: json["total_budget"],
    customerName: json["customer_name"],
    date: json["date"],
    image: json["image"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    // customer: json["customer"] == null ? null : UserData.fromJson(json["customer"]),
    category: json["category"] == null ? null : Category.fromJson(json["category"]),


    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    totalViews: json["total_views"],
    jobPrice: json["job_price"],
    acceptedBidId: json["accepted_bid_id"]??json["cancel_bid_id"],
    advancePercent: json["advance_percent"],
    remainingPercent: json["remaining_percent"],
    proposalsCount: json["proposals_count"],
    countryName: json["country_name"] ?? json["country"],
    stateName: json["state_name"],
    cityName: json["city_name"] ?? json["city"],
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "reason": reason,
    "price": price,
    "provider_id": providerId,
    "customer_id": customerId,
    "customer_profile": customerProfile,
    "status": status,
    "can_bid": canBid,
    "service": service?.map((e) => e.toJson()).toList(),
    "created_at": createdAt,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "country_id": countryId,
    "state_id": stateId,
    "city_id": cityId,
    "start_date": startDate,
    "end_date": endDate,
    "total_days": totalDays,
    "total_hours": totalHours,
    "requirement": requirement,
    "latitude": latitude,
    "longitude": longitude,
    "price_type": priceType?.backendValue,
    "type": type?.backendValue,
    "job_schedule": jobSchedule?.backendValue,
    "remote_work_level": remoteWorkLevel?.backendValue,
    "career_level": careerLevel?.backendValue,
    "education_level": educationLevel?.backendValue,
    "travel_required": travelRequired?.backendValue,
    "street_address": streetAddress,
    "house_number": houseNumber,
    "working_address": workingAddress,
    "duties": duties,
    "benefits": benefits,
    "total_budget": totalBudget,
    "customer_name": customerName,
    "date": date,
    "image": image,
    "updated_at": updatedAt?.toIso8601String(),
    // "customer": customer?.toJson(),
    "category": category?.toJson(),

    "images": List<dynamic>.from(images!.map((x) => x)),
    "job_price": jobPrice,
    "accepted_bid_id": acceptedBidId,
    "total_views": totalViews,
    "advance_percent": advancePercent,
    "remaining_percent": remainingPercent,
  };
}

/// Price Type
enum PriceType {
  hourly("Hourly", "hourly"),
  fixed("Fixed", "fixed"),
  daily("Daily", "daily");

  final String displayName;
  final String backendValue;

  const PriceType(this.displayName, this.backendValue);
}

/// Job Type – each has a distinct bg color for quick visibility
enum JobType {
  onSite("On Site", "onsite", Color(0xFFBBDEFB)),   // light blue
  hybrid("Hybrid", "hybrid", Color(0xFFFFE0B2)),   // orange
  remote("Remote", "remote", Color(0xFFC8E6C9));    // green

  final String displayName;
  final String backendValue;
  final Color bgColor;

  const JobType(this.displayName, this.backendValue, this.bgColor);
}

/// Job Schedule
enum JobSchedule {
  fullTime("Full-time", "full_time"),
  partTime("Part-time", "part_time"),
  contract("Contract", "contract"),
  temporary("Temporary", "temporary"),
  internship("Internship", "internship");

  final String displayName;
  final String backendValue;

  const JobSchedule(this.displayName, this.backendValue);
}

/// Remote Work Level
enum RemoteWorkLevel {
  onsite0("Onsite (100%)", "onsite"),
  remote25("25% Remote", "25_remote"),
  remote50("50% Remote", "50_remote"),
  remote75("75% Remote", "75_remote"),
  remote100("100% Remote", "100_remote");

  final String displayName;
  final String backendValue;

  const RemoteWorkLevel(this.displayName, this.backendValue);
}

/// Career Level
enum CareerLevel {
  notSpecified("Not Specified", "not_specified"),
  entryLevel("Entry Level", "entry_level"),
  intermediateLevel("Intermediate Level", "intermediate_level"),
  experienced("Experienced", "experienced"),
  professional("Professional", "professional"),
  middleManagement("Middle Management", "middle_management"),
  executiveManagement("Executive Management", "executive_management"),
  seniorManagement("Senior Management", "senior_management"),
  director("Director", "director"),
  technician("Technician", "technician"),
  leader("Leader", "leader"),
  manager("Manager", "manager");

  final String displayName;
  final String backendValue;

  const CareerLevel(this.displayName, this.backendValue);
}

/// Travel Requirement
enum TravelRequirement {
  no("No", "0"),
  yes("Yes", "1");

  final String displayName;
  final String backendValue;

  const TravelRequirement(this.displayName, this.backendValue);
}

/// Education Level
enum EducationLevel {
  notSpecified("Not Specified", "not_specified"),
  anyGraduate("Any Graduate", "any_graduate"),
  apprenticeshipDegree("Apprenticeship Degree", "apprenticeship_degree"),
  traineeshipDegree("Traineeship Degree", "traineeship_degree"),
  secondaryDegree("Secondary Degree", "secondary_degree"),
  undergraduateDiploma("Undergraduate Diploma", "undergraduate_diploma"),
  highSchoolGraduate("High school graduate", "high_school_graduate"),
  associateDegree("Associate degree", "associate_degree"),
  collegeDegree("College Degree", "college_degree"),
  universityDegree("University Degree", "university_degree"),
  bachelorsDegree("Bachelor's Degree", "bachelors_degree"),
  mastersDegree("Master's Degree", "masters_degree"),
  doctorateDegree("Doctorate Degree", "doctorate_degree"),
  professionalDegree("Professional Degree", "professional_degree");

  final String displayName;
  final String backendValue;

  const EducationLevel(this.displayName, this.backendValue);
}

/// Profile Education (edit profile dropdown). Blade first option is `''`.
enum ProfileEducationLevel {
  unspecified("—", ""),
  anyGraduate("Any Graduate", "any_graduate"),
  apprenticeshipDegree("Apprenticeship Degree", "apprenticeship_degree"),
  traineeshipDegree("Traineeship Degree", "traineeship_degree"),
  secondaryDegree("Secondary Degree", "secondary_degree"),
  undergraduateDiploma("Undergraduate Diploma", "undergraduate_diploma"),
  highSchoolGraduate("High school graduate", "high_school_graduate"),
  associateDegree("Associate degree", "associate_degree"),
  collegeDegree("College Degree", "college_degree"),
  universityDegree("University Degree", "university_degree"),
  bachelorsDegree("Bachelor's Degree", "bachelors_degree"),
  mastersDegree("Master's Degree", "masters_degree"),
  doctorateDegree("Doctorate Degree", "doctorate_degree"),
  professionalDegree("Professional Degree", "professional_degree");

  final String displayName;
  final String backendValue;

  const ProfileEducationLevel(this.displayName, this.backendValue);
}

/// Years of Experience (edit profile dropdown).
/// API expects string: e.g. `''`, `1_to_3`, `more_than_10` (blade first option is `''`).
enum YearsOfExperience {
  unspecified("—", ""),
  lessThan1Year("Less than 1 Year", "less_than_1"),
  oneTo3Years("1 to 3 Years", "1_to_3"),
  threeTo5Years("3 to 5 Years", "3_to_5"),
  fiveTo8Years("5 to 8 Years", "5_to_8"),
  eightTo10Years("8 to 10 Years", "8_to_10"),
  moreThan10Years("More than 10 Years", "more_than_10");

  final String displayName;
  final String backendValue;

  const YearsOfExperience(this.displayName, this.backendValue);
}

/// Education Level
enum RequestStatus {
  pending('pending',defaultStatus),
  assigned('assigned',primaryColorWithOpacity),
  requested('requested',defaultStatus),
  accepted('accepted',accept),
  pendingAdvance('advance_payment_pending',primaryColorWithOpacity),
  advancePaid('advance_paid',primaryColorWithOpacity),
  inProcess('in_process',primaryColorWithOpacity),
  inProgress('in_progress',primaryColorWithOpacity),
  hold('hold',primaryColorWithOpacity),
  done('done',primaryColorWithOpacity),
  confirmDone('confirm_done',primaryColorWithOpacity),
  completed('completed',primaryColorWithOpacity),
  remainingPaymentPending('remaining_payment_pending',primaryColorWithOpacity),
  remainingPaid('remaining_paid',primaryColorWithOpacity),
  cancel('cancelled',cancelled);

  final String backendValue;
  final Color bgColor;
  const RequestStatus(this.backendValue,this.bgColor);

  String get displayName => switch (this) {
    RequestStatus.pending                 => languages.statusPending,
    RequestStatus.assigned                => languages.statusAssigned,
    RequestStatus.requested               => languages.statusRequested,
    RequestStatus.accepted                => languages.statusAccepted,
    RequestStatus.pendingAdvance          => languages.statusAdvancePaymentPending,
    RequestStatus.advancePaid             => languages.statusAdvancePaid,
    RequestStatus.inProcess               => languages.statusInProcess,
    RequestStatus.inProgress              => languages.statusInProgress,
    RequestStatus.hold                    => languages.statusHold,
    RequestStatus.done                    => languages.statusDone,
    RequestStatus.confirmDone             => languages.statusConfirmDone,
    RequestStatus.completed               => languages.statusCompleted,
    RequestStatus.remainingPaymentPending => languages.statusRemainingPaymentPending,
    RequestStatus.remainingPaid           => languages.statusRemainingPaid,
    RequestStatus.cancel                  => languages.statusCancelled,
  };

  /// Parses status from API. Accepts snake_case and "Display Form" for pending statuses.
  static RequestStatus fromJson(dynamic value) {
    if (value == null) return RequestStatus.requested;
    final s = value.toString().trim();
    final sLower = s.toLowerCase();
    final sNormalized = sLower.replaceAll(' ', '_');
    if (s == 'Advance Payment Pending' || sNormalized == 'advance_payment_pending') return RequestStatus.pendingAdvance;
    if (s == 'Remaining Payment Pending' || sNormalized == 'remaining_payment_pending' || sLower == 'remaining payment pending') return RequestStatus.remainingPaymentPending;
    return RequestStatus.values.firstWhere((e) => e.backendValue == s || e.backendValue == sLower || e.backendValue == sNormalized, orElse: () => RequestStatus.requested);
  }
}


class Category {
  int? id;
  String? name;
  String? description;
  String? color;
  int? status;
  int? isFeatured;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.description,
    this.color,
    this.status,
    this.isFeatured,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    color: json["color"],
    status: json["status"],
    isFeatured: json["is_featured"],
    deletedAt: json["deleted_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "color": color,
    "status": status,
    "is_featured": isFeatured,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}