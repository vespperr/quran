import 'dart:convert';

/// Root manifest for bundled + remote Quran recitation audio (see [assets/json/recitations_manifest.json]).
class RecitationManifest {
  RecitationManifest({
    required this.version,
    required this.defaultReciterId,
    required this.reciters,
  });

  final int version;
  final String defaultReciterId;
  final List<ReciterInfo> reciters;

  ReciterInfo? byId(String id) {
    for (final r in reciters) {
      if (r.id == id) return r;
    }
    return null;
  }

  static RecitationManifest fromJson(Map<String, dynamic> json) {
    final list = json['reciters'] as List<dynamic>? ?? const [];
    return RecitationManifest(
      version: json['version'] as int? ?? 1,
      defaultReciterId: json['defaultReciterId'] as String? ?? '',
      reciters: list
          .map((e) => ReciterInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static RecitationManifest parse(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class ReciterInfo {
  ReciterInfo({
    required this.id,
    required this.displayName,
    this.remoteAyahUrlTemplate,
    this.bundledDemoAssetPath,
    this.bundledDemoAyahId,
  });

  final String id;
  final Map<String, String> displayName;
  final String? remoteAyahUrlTemplate;
  final String? bundledDemoAssetPath;
  final int? bundledDemoAyahId;

  String labelForLocale(String languageCode) {
    return displayName[languageCode] ??
        displayName['en'] ??
        displayName.values.first;
  }

  static ReciterInfo fromJson(Map<String, dynamic> json) {
    final names = json['displayName'];
    final Map<String, String> map = {};
    if (names is Map<String, dynamic>) {
      names.forEach((k, v) {
        if (v is String) map[k] = v;
      });
    }
    return ReciterInfo(
      id: json['id'] as String? ?? '',
      displayName: map,
      remoteAyahUrlTemplate: json['remoteAyahUrlTemplate'] as String?,
      bundledDemoAssetPath: json['bundledDemoAssetPath'] as String?,
      bundledDemoAyahId: json['bundledDemoAyahId'] as int?,
    );
  }
}
