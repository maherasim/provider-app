class ReportProfileReason {
  final String value;
  final String label;

  ReportProfileReason({required this.value, required this.label});

  factory ReportProfileReason.fromJson(Map<String, dynamic> json) {
    return ReportProfileReason(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}
