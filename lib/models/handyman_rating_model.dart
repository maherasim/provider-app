class HandymanRatingModel {
  int? id;
  int? bookingId;
  HandymanRatingCustomer? customer;
  HandymanRatingService? service;
  num? rating;
  String? review;
  String? createdAt;
  String? updatedAt;

  HandymanRatingModel({
    this.id,
    this.bookingId,
    this.customer,
    this.service,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory HandymanRatingModel.fromJson(Map<String, dynamic> json) {
    return HandymanRatingModel(
      id: json['id'],
      bookingId: json['booking_id'],
      customer: json['customer'] != null ? HandymanRatingCustomer.fromJson(json['customer']) : null,
      service: json['service'] != null ? HandymanRatingService.fromJson(json['service']) : null,
      rating: json['rating'],
      review: json['review'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    data['rating'] = rating;
    data['review'] = review;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class HandymanRatingCustomer {
  int? id;
  String? name;
  String? profileImage;
  String? address;

  HandymanRatingCustomer({
    this.id,
    this.name,
    this.profileImage,
    this.address,
  });

  factory HandymanRatingCustomer.fromJson(Map<String, dynamic> json) {
    return HandymanRatingCustomer(
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

class HandymanRatingService {
  int? id;
  String? name;

  HandymanRatingService({
    this.id,
    this.name,
  });

  factory HandymanRatingService.fromJson(Map<String, dynamic> json) {
    return HandymanRatingService(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class HandymanRatingResponse {
  HandymanRatingPagination? pagination;
  List<HandymanRatingModel>? data;

  HandymanRatingResponse({
    this.pagination,
    this.data,
  });

  factory HandymanRatingResponse.fromJson(Map<String, dynamic> json) {
    return HandymanRatingResponse(
      pagination: json['pagination'] != null
          ? HandymanRatingPagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => HandymanRatingModel.fromJson(e)).toList()
          : null,
    );
  }
}

class HandymanRatingPagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;
  int? from;
  int? to;
  String? nextPageUrl;
  String? previousPageUrl;

  HandymanRatingPagination({
    this.totalItems,
    this.perPage,
    this.currentPage,
    this.totalPages,
    this.from,
    this.to,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory HandymanRatingPagination.fromJson(Map<String, dynamic> json) {
    return HandymanRatingPagination(
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
