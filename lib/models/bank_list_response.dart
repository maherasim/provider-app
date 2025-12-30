class BankListResponse {
  Pagination pagination;
  List<BankHistory> data;

  BankListResponse({
    required this.pagination,
    this.data = const <BankHistory>[],
  });

  factory BankListResponse.fromJson(Map<String, dynamic> json) {
    return BankListResponse(
      pagination: json['pagination'] is Map ? Pagination.fromJson(json['pagination']) : Pagination(),
      data: json['data'] is List ? List<BankHistory>.from(json['data'].map((x) => BankHistory.fromJson(x))) : [],
    );
  }

  get id => null;

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Pagination {
  int totalItems;
  int perPage;
  int currentPage;
  int totalPages;
  int from;
  int to;
  dynamic nextPage;
  dynamic previousPage;

  Pagination({
    this.totalItems = -1,
    this.perPage = -1,
    this.currentPage = -1,
    this.totalPages = -1,
    this.from = -1,
    this.to = -1,
    this.nextPage,
    this.previousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: json['total_items'] is int ? json['total_items'] : -1,
      perPage: json['per_page'] is int ? json['per_page'] : -1,
      currentPage: json['currentPage'] is int ? json['currentPage'] : -1,
      totalPages: json['totalPages'] is int ? json['totalPages'] : -1,
      from: json['from'] is int ? json['from'] : -1,
      to: json['to'] is int ? json['to'] : -1,
      nextPage: json['next_page'],
      previousPage: json['previous_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'per_page': perPage,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'from': from,
      'to': to,
      'next_page': nextPage,
      'previous_page': previousPage,
    };
  }
}

class BankHistory {
  int id;
  int providerId;
  String bankName;
  String branchName;
  String accountNo;
  String accountHolder;
  String ifscNo;
  String ibanNo;
  String bicNumber;
  String mobileNo;
  String aadharNo;
  String panNo;
  String stripeAccount;
  List<dynamic> bankAttchments;
  int isDefault;
  int status;

  BankHistory({
    this.id = -1,
    this.providerId = -1,
    this.bankName = "",
    this.branchName = "",
    this.accountNo = "",
    this.accountHolder = "",
    this.ifscNo = "",
    this.ibanNo = "",
    this.bicNumber = "",
    this.mobileNo = "",
    this.aadharNo = "",
    this.panNo = "",
    this.stripeAccount = "",
    this.bankAttchments = const [],
    this.isDefault = -1,
    this.status = 1,
  });

  static String _parseString(dynamic value) {
    if (value == null) return "";
    String str = value.toString().trim();
    if (str.isEmpty || str == "null" || str == "Null" || str == "NULL") return "";
    return str;
  }

  factory BankHistory.fromJson(Map<String, dynamic> json) {
    return BankHistory(
      id: json['id'] is int ? json['id'] : -1,
      providerId: json['provider_id'] is int ? json['provider_id'] : -1,
      bankName: _parseString(json['bank_name']),
      branchName: _parseString(json['branch_name']),
      accountNo: _parseString(json['account_no']),
      accountHolder: _parseString(json['account_holder']),
      ifscNo: _parseString(json['ifsc_no']),
      ibanNo: _parseString(json['iban_no']),
      bicNumber: _parseString(json['bic_number']),
      mobileNo: _parseString(json['mobile_no']),
      aadharNo: _parseString(json['aadhar_no']),
      panNo: _parseString(json['pan_no']),
      stripeAccount: _parseString(json['stripe_account']),
      bankAttchments: json['bank_attchments'] is List ? json['bank_attchments'] : (json['bank_attachment'] != null ? [json['bank_attachment']] : []),
      isDefault: json['is_default'] is int ? json['is_default'] : (json['is_default'] != null ? int.tryParse(json['is_default'].toString()) ?? -1 : -1),
      status: json['status'] is int ? json['status'] : (json['status'] != null ? int.tryParse(json['status'].toString()) ?? 1 : 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_no': accountNo,
      'account_holder': accountHolder,
      'ifsc_no': ifscNo,
      'iban_no': ibanNo,
      'bic_number': bicNumber,
      'mobile_no': mobileNo,
      'aadhar_no': aadharNo,
      'pan_no': panNo,
      'stripe_account': stripeAccount,
      'bank_attchments': [],
      'is_default': isDefault,
      'status': status,
    };
  }
}
