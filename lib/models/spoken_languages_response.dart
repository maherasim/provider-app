/// Response from `GET spoken-languages` (see `/api/spoken-languages`).
class SpokenLanguagesResponse {
  final Map<String, String> options;

  SpokenLanguagesResponse({required this.options});

  factory SpokenLanguagesResponse.fromJson(dynamic json) {
    final Map<String, String> out = {};
    if (json is! Map) {
      return SpokenLanguagesResponse(options: out);
    }
    final root = Map<String, dynamic>.from(json);

    void addOptions(Map? m) {
      if (m == null) return;
      m.forEach((k, v) {
        if (k != null && v != null) {
          out[k.toString()] = v.toString();
        }
      });
    }

    void addFromList(List? list) {
      if (list == null) return;
      for (final e in list) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final code = m['code']?.toString() ?? '';
          final name = m['name']?.toString() ?? '';
          if (code.isNotEmpty) {
            out[code] = name.isNotEmpty ? name : code;
          }
        }
      }
    }

    final data = root['data'];
    if (data is List) {
      addFromList(data);
      final opts = root['options'];
      addOptions(opts is Map ? Map<String, dynamic>.from(opts) : null);
    } else if (data is Map) {
      final inner = Map<String, dynamic>.from(data);
      if (inner['data'] is List) {
        addFromList(List<dynamic>.from(inner['data'] as List));
      }
      final innerOpts = inner['options'];
      addOptions(innerOpts is Map ? Map<String, dynamic>.from(innerOpts) : null);
      final rootOpts = root['options'];
      addOptions(rootOpts is Map ? Map<String, dynamic>.from(rootOpts) : null);
    } else {
      final fallbackOpts = root['options'];
      addOptions(fallbackOpts is Map ? Map<String, dynamic>.from(fallbackOpts) : null);
    }

    return SpokenLanguagesResponse(options: out);
  }
}
