import 'dart:convert';

import 'package:handyman_provider_flutter/models/package_response.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/model_keys.dart';
import 'multi_language_request_model.dart';



class ServiceData {
  int? id;
  String? name;
  int? categoryId;
  int? subCategoryId;
  int? providerId;
  num? price;
  var priceFormat;
  String? type;
  num? discount;
  String? duration;
  String? cancellationPolicy;
  String? minimumBookings;
    String? countryTax;
  int? status;
  String? description;
  String? requirements;
  int? isFeatured;
  String? providerName;
  String? providerImage;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  int? stateId;
  String? categoryName;
  List<String>? imageAttachments;
  List<Attachments>? attchments;
  num? totalReview;
  num? totalRating;
  int? isFavourite;
  num? views;
  num? totalBookingCount;
  num? completedBookingCount;
  bool? showEditDeleteButtons;
  List<ServiceAddressMapping>? serviceAddressMapping;
  Map<String, MultiLanguageRequest>? translations;

  //Set Values
  num? totalAmount;
  num? discountPrice;
  num? taxAmount;
  num? couponDiscountAmount;
  String? dateTimeVal;
  String? couponId;
  num? qty;
  String? address;
  int? bookingAddressId;
  CouponData? appliedCouponData;
  num? isSlot;
  String? visitType;
  List<SlotData>? providerSlotData;
  List<PackageData>? servicePackage;
  num? advancePaymentSetting;
  num? isEnableAdvancePayment;
  num? advancePaymentAmount;
  num? advancePaymentPercentage;
  String? remoteWorkLevel;
  String? careerLevel;
  String? travelRequired;

  //Local
  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isDailyService => type.validate() == SERVICE_TYPE_DAILY;

  bool get isFixedService => type.validate() == SERVICE_TYPE_FIXED;

  bool get isFreeService => price.validate() == 0;

  bool get isAdvancePayment => isEnableAdvancePayment.validate() == 1;

  bool get isAdvancePaymentSetting => advancePaymentSetting.validate() == 1;

  String? subCategoryName;

  bool? isSelected;

  bool get isOnlineService => visitType == VISIT_OPTION_ONLINE;

  bool get isOnSiteService => visitType == VISIT_OPTION_ON_SITE;

  ServiceData(
      {this.id,
      this.name,
      this.imageAttachments,
      this.providerSlotData,
      this.categoryId,
      this.providerId,
      this.price,
      this.priceFormat,
      this.type,
      this.discount,
      this.cancellationPolicy,
      this.countryTax,
      this.minimumBookings,
      this.status,
      this.isSlot,
      this.visitType,
      this.description,
      this.requirements,
      this.isFeatured,
      this.providerName,
      this.subCategoryId,
      this.providerImage,
      this.countryId,
      this.stateId,
      
      this.cityId,
      this.categoryName,
      this.attchments,
      this.totalReview,
      this.totalRating,
      this.isFavourite,
      this.serviceAddressMapping,
      this.totalAmount,
      this.discountPrice,
      this.taxAmount,
      this.couponDiscountAmount,
      this.dateTimeVal,
      this.couponId,
      this.subCategoryName,
      this.qty,
      this.address,
      this.bookingAddressId,
      this.appliedCouponData,
      this.isSelected,
      this.servicePackage,
      this.advancePaymentSetting,
      this.isEnableAdvancePayment,
      this.advancePaymentAmount,
      this.advancePaymentPercentage,
      this.remoteWorkLevel,
      this.careerLevel,
      this.travelRequired,
      this.translations});

  ServiceData.fromJson(Map<String, dynamic> json) {
    // Handle id - can be string or num
    if (json['id'] != null) {
      var idValue = json['id'];
      if (idValue is int) {
        id = idValue;
      } else if (idValue is num) {
        id = idValue.toInt();
      } else if (idValue is String) {
        id = int.tryParse(idValue);
      }
    }
    name = json['name'];
    providerImage = json['provider_image'];
    // Handle category_id - can be string or num
    if (json['category_id'] != null) {
      var categoryIdValue = json['category_id'];
      if (categoryIdValue is int) {
        categoryId = categoryIdValue;
      } else if (categoryIdValue is num) {
        categoryId = categoryIdValue.toInt();
      } else if (categoryIdValue is String) {
        categoryId = int.tryParse(categoryIdValue);
      }
    }
    // Handle subcategory_id - can be string or num
    if (json['subcategory_id'] != null) {
      var subCategoryIdValue = json['subcategory_id'];
      if (subCategoryIdValue is int) {
        subCategoryId = subCategoryIdValue;
      } else if (subCategoryIdValue is num) {
        subCategoryId = subCategoryIdValue.toInt();
      } else if (subCategoryIdValue is String) {
        subCategoryId = int.tryParse(subCategoryIdValue);
      }
    }
    // Handle provider_id - can be string or num
    if (json['provider_id'] != null) {
      var providerIdValue = json['provider_id'];
      if (providerIdValue is int) {
        providerId = providerIdValue;
      } else if (providerIdValue is num) {
        providerId = providerIdValue.toInt();
      } else if (providerIdValue is String) {
        providerId = int.tryParse(providerIdValue);
      }
    }
    // Handle price - can be string or num
    if (json['price'] != null) {
      price = json['price'] is num ? json['price'] : (json['price'] is String ? double.tryParse(json['price']) : null);
    }
    priceFormat = json['price_format'];
    type = json['type'];
    // Handle discount - can be string or num
    if (json['discount'] != null) {
      discount = json['discount'] is num ? json['discount'] : (json['discount'] is String ? double.tryParse(json['discount']) : null);
    }
    duration = _parseDuration(json['duration']);
    cancellationPolicy = json['cancellation_policy'];
    countryTax = json['tax_country_id'].toString();
    minimumBookings = json['minimum_booking']?.toString();
    // Handle status - can be string or num
    if (json['status'] != null) {
      var statusValue = json['status'];
      if (statusValue is int) {
        status = statusValue;
      } else if (statusValue is num) {
        status = statusValue.toInt();
      } else if (statusValue is String) {
        status = int.tryParse(statusValue);
      }
    }
    // Handle is_slot - can be string or num
    if (json['is_slot'] != null) {
      var isSlotValue = json['is_slot'];
      if (isSlotValue is int) {
        isSlot = isSlotValue;
      } else if (isSlotValue is num) {
        isSlot = isSlotValue.toInt();
      } else if (isSlotValue is String) {
        isSlot = int.tryParse(isSlotValue);
      }
    }
    visitType = _normalizeVisitType(json['visit_type']);
    description = json['description'];
    requirements = json['requirements'];
    // Handle is_featured - can be string or num
    if (json['is_featured'] != null) {
      var isFeaturedValue = json['is_featured'];
      if (isFeaturedValue is int) {
        isFeatured = isFeaturedValue;
      } else if (isFeaturedValue is num) {
        isFeatured = isFeaturedValue.toInt();
      } else if (isFeaturedValue is String) {
        isFeatured = int.tryParse(isFeaturedValue);
      }
    }
    providerName = json['provider_name'];
    // Handle both camelCase and snake_case for country_id - can be string or num
    var countryIdValue = json['countryId'] ?? json['country_id'];
    if (countryIdValue != null) {
      if (countryIdValue is int) {
        countryId = countryIdValue;
      } else if (countryIdValue is num) {
        countryId = countryIdValue.toInt();
      } else if (countryIdValue is String) {
        countryId = int.tryParse(countryIdValue);
      }
    }
    // Some APIs return human-readable names
    countryName = json['country_name'];
    // Handle both camelCase and snake_case for state_id - can be string or num
    var stateIdValue = json['stateId'] ?? json['state_id'];
    if (stateIdValue != null) {
      if (stateIdValue is int) {
        stateId = stateIdValue;
      } else if (stateIdValue is num) {
        stateId = stateIdValue.toInt();
      } else if (stateIdValue is String) {
        stateId = int.tryParse(stateIdValue);
      }
    }
    // Handle city_id - can be string or num
    if (json['city_id'] != null) {
      var cityIdValue = json['city_id'];
      if (cityIdValue is int) {
        cityId = cityIdValue;
      } else if (cityIdValue is num) {
        cityId = cityIdValue.toInt();
      } else if (cityIdValue is String) {
        cityId = int.tryParse(cityIdValue);
      }
    }
    cityName = json['city_name'];
    categoryName = json['category_name'];
    //image_attchments = json['attchments'];
    imageAttachments = json['attchments'] != null
        ? List<String>.from(json['attchments'])
        : null;
    attchments = json['attchments_array'] != null
        ? (json['attchments_array'] as List)
            .map((i) => Attachments.fromJson(i))
            .toList()
        : null;
    providerSlotData = json['slots'] != null
        ? (json['slots'] as List).map((i) => SlotData.fromJson(i)).toList()
        : null;
    subCategoryName = json['subcategory_name'];
    translations = json['translations'] != null
        ? (jsonDecode(json['translations']) as Map<String, dynamic>).map(
            (key, value) {
              if (value is Map<String, dynamic>) {
                return MapEntry(key, MultiLanguageRequest.fromJson(value));
              } else {
                print('Unexpected translation value for key $key: $value');
                return MapEntry(key, MultiLanguageRequest());
              }
            },
          )
        : null;
    // Handle total_review - can be string or num
    if (json['total_review'] != null) {
      totalReview = json['total_review'] is num ? json['total_review'] : (json['total_review'] is String ? double.tryParse(json['total_review']) : null);
    }
    // Handle total_rating - can be string or num
    if (json['total_rating'] != null) {
      totalRating = json['total_rating'] is num ? json['total_rating'] : (json['total_rating'] is String ? double.tryParse(json['total_rating']) : null);
    }
    // Handle is_favourite - can be string or num
    if (json['is_favourite'] != null) {
      var isFavouriteValue = json['is_favourite'];
      if (isFavouriteValue is int) {
        isFavourite = isFavouriteValue;
      } else if (isFavouriteValue is num) {
        isFavourite = isFavouriteValue.toInt();
      } else if (isFavouriteValue is String) {
        isFavourite = int.tryParse(isFavouriteValue);
      }
    }
    views = json['views'] ?? json['total_views'];
    totalBookingCount = json['total_booking_count'];
    completedBookingCount = json['completed_booking_count'];
    if (json['show_edit_delete_buttons'] != null) {
      final v = json['show_edit_delete_buttons'];
      showEditDeleteButtons = v == true || v == 1 || v == '1';
    }

    if (json['service_address_mapping'] != null) {
      serviceAddressMapping = [];
      json['service_address_mapping'].forEach((v) {
        serviceAddressMapping!.add(new ServiceAddressMapping.fromJson(v));
      });
    }
    servicePackage = json['servicePackage'] != null
        ? (json['servicePackage'] as List)
            .map((i) => PackageData.fromJson(i))
            .toList()
        : null;
    advancePaymentSetting = json[AdvancePaymentKey.advancePaymentSetting];
    isEnableAdvancePayment = json[AdvancePaymentKey.isEnableAdvancePayment];
    
    // Handle advance_payment_amount - just fetch the value directly, no calculation
    if (json[AdvancePaymentKey.advancePaymentAmount] != null) {
      var amountValue = json[AdvancePaymentKey.advancePaymentAmount];
      if (amountValue is num) {
        advancePaymentAmount = amountValue;
      } else if (amountValue is String) {
        advancePaymentAmount = double.tryParse(amountValue);
      }
      print('🔵 MODEL: Fetched advancePaymentAmount=$advancePaymentAmount directly from API');
    }
    
    // Handle advance_payment_percentage - store as string to preserve "%" sign for display
    if (json['advance_payment_percentage'] != null) {
      var percentageValue = json['advance_payment_percentage'];
      // Store as string to preserve the "%" sign (e.g., "20%")
      if (percentageValue is String) {
        advancePaymentPercentage = double.tryParse(percentageValue.replaceAll('%', '').trim());
      } else if (percentageValue is num) {
        advancePaymentPercentage = percentageValue.toDouble();
      }
      print('🔵 MODEL: Fetched advance_payment_percentage=$percentageValue from API');
    }
    
    // Handle remote_work_level - can be string, null, or other types
    if (json['remote_work_level'] != null) {
      remoteWorkLevel = json['remote_work_level'].toString();
    }
    
    // Handle career_level - can be string, null, or other types
    if (json['career_level'] != null) {
      careerLevel = json['career_level'].toString();
    }
    
    // Handle travel_required - can be bool (0/1), int, string, or null
    if (json['travel_required'] != null) {
      if (json['travel_required'] is bool) {
        travelRequired = json['travel_required'] ? '1' : '0';
      } else {
        travelRequired = json['travel_required'].toString();
      }
    }
  }

  /// API may send duration as minutes (e.g. 60) or "H:MM" string. Normalize to "H:MM".
  static String? _parseDuration(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is int || v is num) {
      int totalMinutes = (v is int) ? v : (v as num).toInt();
      int h = totalMinutes ~/ 60;
      int m = totalMinutes % 60;
      return '$h:$m';
    }
    return v.toString();
  }

  /// API may send visit_type as "at_customer". Map to app constant "on_site".
  static String? _normalizeVisitType(dynamic v) {
    if (v == null) return null;
    String s = v.toString().trim().toLowerCase();
    if (s == 'at_customer') return VISIT_OPTION_ON_SITE;
    return s.isNotEmpty ? s : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['provider_image'] = this.providerImage;
    data['category_id'] = this.categoryId;
    data['provider_id'] = this.providerId;
    if (this.cityName != null) data['city_name'] = this.cityName;
    if (this.countryName != null) data['country_name'] = this.countryName;
    data['is_slot'] = this.isSlot;
    data['visit_type'] = this.visitType;
    data['price'] = this.price;
    data['price_format'] = this.priceFormat;
    data['type'] = this.type;
    data['discount'] = this.discount;
    data['minimum_booking'] = this.minimumBookings;
    data['status'] = this.status;
    data['description'] = this.description;
    data['requirements'] = this.requirements;
    data['is_featured'] = this.isFeatured;
    data['provider_name'] = this.providerName;
    data['city_id'] = this.cityId;
    data['subcategory_id'] = this.subCategoryId;
    data['subcategory_name'] = this.subCategoryName;

    data['category_name'] = this.categoryName;
    if (this.imageAttachments != null) {
      data['attchments'] = this.imageAttachments;
    }
    if (this.providerSlotData != null) {
      data['slots'] = this.providerSlotData;
    }
    if (this.servicePackage != null) {
      data['servicePackage'] =
          this.servicePackage!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] =
          translations!.map((key, value) => MapEntry(key, value.toJson()));
    }
    data['total_review'] = this.totalReview;
    data['total_rating'] = this.totalRating;
    data['is_favourite'] = this.isFavourite;
    if (this.serviceAddressMapping != null) {
      data['service_address_mapping'] =
          this.serviceAddressMapping!.map((v) => v.toJson()).toList();
    }
    if (this.attchments != null) {
      data['attchments_array'] =
          this.attchments!.map((v) => v.toJson()).toList();
    }

    data[AdvancePaymentKey.advancePaymentSetting] = this.advancePaymentSetting;
    data[AdvancePaymentKey.isEnableAdvancePayment] =
        this.isEnableAdvancePayment;
    data[AdvancePaymentKey.advancePaymentAmount] = this.advancePaymentAmount;
    data[AdvancePaymentKey.advancePaymentAmount] =
        this.advancePaymentPercentage;
    return data;
  }
}
