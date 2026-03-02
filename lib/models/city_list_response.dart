class CityListResponse {
  int? id;
  String? name;
  int? stateId;

  CityListResponse({this.id, this.name, this.stateId});

  factory CityListResponse.fromJson(Map<String, dynamic> json) {
    return CityListResponse(
      id: _parseInt(json['id']),
      name: json['name'],
      stateId: _parseInt(json['state_id']),
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
    data['id'] = this.id;
    data['name'] = this.name;
    data['state_id'] = this.stateId;
    return data;
  }
}
