class WalletResponse {
  num? balance;

  WalletResponse({this.balance});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    num? balance;
    if (json['balance'] != null) {
      final v = json['balance'];
      if (v is num) balance = v;
      else if (v is String) balance = num.tryParse(v);
    }
    return WalletResponse(
      balance: balance,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    return data;
  }
}
