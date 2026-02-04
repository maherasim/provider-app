class PostJobPaymentData {
  int? id;
  int? customerId;
  String? customerName;
  int? postJobBidRequestId;
  num? discount;
  num? totalAmount;
  String? paymentType;
  String? txnId;
  String? paymentStatus;
  String? otherTransactionDetail;
  String? jobTitle;
  String? datetime;
  DateTime? dateTime;
  String? createdAt;
  String? updatedAt;

  PostJobPaymentData({
    this.id,
    this.customerId,
    this.customerName,
    this.postJobBidRequestId,
    this.discount,
    this.totalAmount,
    this.paymentType,
    this.txnId,
    this.paymentStatus,
    this.otherTransactionDetail,
    this.jobTitle,
    this.datetime,
    this.dateTime,
    this.createdAt,
    this.updatedAt,
  });

  factory PostJobPaymentData.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDateTime;
    if (json['datetime'] != null) {
      try {
        parsedDateTime = DateTime.parse(json['datetime']);
      } catch (e) {
        parsedDateTime = null;
      }
    }

    return PostJobPaymentData(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      customerId: json['customer_id'] is int ? json['customer_id'] : (json['customer_id'] != null ? int.tryParse(json['customer_id'].toString()) : null),
      customerName: json['customer_name'],
      postJobBidRequestId: json['post_job_bid_request_id'] is int ? json['post_job_bid_request_id'] : (json['post_job_bid_request_id'] != null ? int.tryParse(json['post_job_bid_request_id'].toString()) : null),
      discount: json['discount'],
      totalAmount: json['total_amount'],
      paymentType: json['payment_type'],
      txnId: json['txn_id'],
      paymentStatus: json['payment_status'],
      otherTransactionDetail: json['other_transaction_detail'],
      jobTitle: json['job_title'],
      datetime: json['datetime'],
      dateTime: parsedDateTime,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'customer_name': customerName,
    'post_job_bid_request_id': postJobBidRequestId,
    'discount': discount,
    'total_amount': totalAmount,
    'payment_type': paymentType,
    'txn_id': txnId,
    'payment_status': paymentStatus,
    'other_transaction_detail': otherTransactionDetail,
    'job_title': jobTitle,
    'datetime': datetime,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
