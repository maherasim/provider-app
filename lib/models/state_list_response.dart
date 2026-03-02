class StateListResponse {
  int? countryId;
  int? id;
  String? name;

  StateListResponse({this.countryId, this.id, this.name});

  factory StateListResponse.fromJson(Map<String, dynamic> json) {
    return StateListResponse(
      countryId: json['country_id'],
      id: _parseInt(json['id']),
      name: json['name'],
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_id'] = this.countryId;
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
