class AppVersionInfo {
  final String latestVersion;
  final String storeUrl;
  final String? releaseNotes;

  const AppVersionInfo({
    required this.latestVersion,
    required this.storeUrl,
    this.releaseNotes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latestVersion']?.toString() ?? '0.0.0',
      storeUrl: json['storeUrl']?.toString() ?? '',
      releaseNotes: json['releaseNotes']?.toString(),
    );
  }
}
