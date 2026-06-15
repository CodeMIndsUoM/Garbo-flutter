import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:garbo_swms/core/utils/version_utils.dart';
import 'package:garbo_swms/data/models/app_version_info.dart';
import 'package:garbo_swms/data/sources/app_version_api.dart';

class AppUpdateProvider extends ChangeNotifier {
  final AppVersionApi _api;

  String? _currentVersion;
  AppVersionInfo? _remoteInfo;
  bool _isLoading = false;
  bool _initialized = false;

  AppUpdateProvider({required AppVersionApi api}) : _api = api;

  String? get currentVersion => _currentVersion;
  AppVersionInfo? get remoteInfo => _remoteInfo;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;

  bool get updateAvailable {
    final current = _currentVersion;
    final latest = _remoteInfo?.latestVersion;
    if (current == null || latest == null || latest.isEmpty) return false;
    return isUpdateAvailable(current, latest);
  }

  String? get latestVersion => _remoteInfo?.latestVersion;
  String? get storeUrl {
    final url = _remoteInfo?.storeUrl;
    if (url == null || url.isEmpty) return null;
    return url;
  }

  String? get releaseNotes {
    final notes = _remoteInfo?.releaseNotes;
    if (notes == null || notes.isEmpty) return null;
    return notes;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
    } catch (_) {
      _currentVersion = null;
    }
    await refresh();
    _initialized = true;
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentVersion == null) {
        final info = await PackageInfo.fromPlatform();
        _currentVersion = info.version;
      }
      _remoteInfo = await _api.fetchLatestVersion();
    } catch (_) {
      // Keep previous remote info on transient failures.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
