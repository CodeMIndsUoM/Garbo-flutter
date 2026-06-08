import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

/// LeaderboardProvider manages real-time leaderboard data from WebSocket updates
class LeaderboardProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConstants.baseUrl;

  final WebSocketProvider webSocketProvider;

  List<LeaderboardEntryDto> _leaderboardEntries = [];
  String? _errorMessage;
  int _lastUpdateTime = 0;
  LeaderboardChangedUserPayload? _lastChangedUser;
  LeaderboardEntryDto? _userRankEntry;
  int? _trackedUserId;
  String? _trackedRole;
  bool _isLoadingSnapshot = false;
  bool _isLoadingUserRank = false;
  bool _pendingSnapshotReload = false;
  Timer? _trackedUserRefreshDebounce;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _messageSubscription;

  List<LeaderboardEntryDto> get leaderboardEntries => _leaderboardEntries;
  String? get errorMessage => _errorMessage;
  int get lastUpdateTime => _lastUpdateTime;
  LeaderboardChangedUserPayload? get lastChangedUser => _lastChangedUser;
  LeaderboardEntryDto? get userRankEntry => _userRankEntry;
  bool get hasData => _leaderboardEntries.isNotEmpty;
  bool get isLoadingSnapshot => _isLoadingSnapshot;

  LeaderboardProvider(this.webSocketProvider) {
    _listenToLeaderboardUpdates();
  }

  void trackUser(int? userId, {String? role}) {
    final normalizedRole = _normalizeRole(role);
    if (_trackedUserId == userId && _trackedRole == normalizedRole) {
      return;
    }

    if (userId == null) {
      reset();
      return;
    }

    final switchedUser = _trackedUserId != null && _trackedUserId != userId;
    _trackedUserId = userId;
    _trackedRole = normalizedRole;
    if (switchedUser) {
      _userRankEntry = null;
      _lastChangedUser = null;
    }
    loadSnapshot();
  }

  void reset() {
    _trackedUserRefreshDebounce?.cancel();
    _trackedUserRefreshDebounce = null;
    _leaderboardEntries = [];
    _userRankEntry = null;
    _lastChangedUser = null;
    _lastUpdateTime = 0;
    _errorMessage = null;
    _trackedUserId = null;
    _trackedRole = null;
    _pendingSnapshotReload = false;
    notifyListeners();
  }

  Future<void> loadSnapshot({int limit = 10}) async {
    if (_isLoadingSnapshot) {
      _pendingSnapshotReload = true;
      return;
    }

    _isLoadingSnapshot = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final headers = await _buildAuthHeaders();
      final roleQuery = _trackedRole != null && _trackedRole!.isNotEmpty
          ? '?role=${Uri.encodeQueryComponent(_trackedRole!)}&limit=$limit'
          : '?limit=$limit';
      final response = await http
          .get(
            Uri.parse('$_baseUrl/leaderboard/top$roleQuery'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        _errorMessage = 'Failed to load leaderboard (${response.statusCode})';
        notifyListeners();
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] is! Map<String, dynamic>) {
        _errorMessage =
            body['message']?.toString() ?? 'Failed to load leaderboard';
        notifyListeners();
        return;
      }

      final payload = body['data'] as Map<String, dynamic>;
      final leaderboardData = LeaderboardUpdatePayload.fromJson(payload);
      _leaderboardEntries = _filterEntriesByTrackedRole(
        leaderboardData.entries,
      );
      _lastUpdateTime = leaderboardData.updatedAt;
      _lastChangedUser = _isChangedUserForTrackedUser(leaderboardData.changedUser)
          ? leaderboardData.changedUser
          : null;
      if (_trackedUserId == null) {
        _userRankEntry = null;
      } else {
        await fetchUserRank(_trackedUserId!, role: _trackedRole);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load leaderboard snapshot: $e');
      _errorMessage = 'Failed to load leaderboard: $e';
      notifyListeners();
    } finally {
      _isLoadingSnapshot = false;
      notifyListeners();
      if (_pendingSnapshotReload) {
        _pendingSnapshotReload = false;
        unawaited(loadSnapshot(limit: limit));
      }
    }
  }

  /// Fetch the current logged-in user's rank from the server
  Future<void> fetchUserRank(
    int userId, {
    String? role,
    bool forceRemote = false,
  }) async {
    if (_trackedUserId != userId) {
      return;
    }

    final normalizedRole = _normalizeRole(role ?? _trackedRole);
    if (!forceRemote && _leaderboardEntries.isNotEmpty) {
      try {
        final topEntry = _leaderboardEntries.firstWhere(
          (entry) => entry.userId == userId,
        );
        _userRankEntry = topEntry;
        notifyListeners();
        return;
      } catch (_) {
        // User is outside the current top list; fetch their rank directly.
      }
    }

    if (_isLoadingUserRank) {
      return;
    }

    _isLoadingUserRank = true;
    try {
      final headers = await _buildAuthHeaders();
      final roleQuery = normalizedRole != null && normalizedRole.isNotEmpty
          ? '?role=${Uri.encodeQueryComponent(normalizedRole)}'
          : '';
      final response = await http
          .get(
            Uri.parse('$_baseUrl/leaderboard/user/$userId$roleQuery'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

      if (_trackedUserId != userId) {
        return;
      }

      if (response.statusCode != 200) {
        _userRankEntry = null;
        notifyListeners();
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        _userRankEntry = null;
        notifyListeners();
        return;
      }

      final data = body['data'];
      if (data != null && data is Map<String, dynamic>) {
        _userRankEntry = LeaderboardEntryDto.fromJson(data);
      } else {
        _userRankEntry = null;
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch user rank: $e');
      if (_trackedUserId == userId) {
        _userRankEntry = null;
      }
    } finally {
      _isLoadingUserRank = false;
    }
  }

  /// Listen to LEADERBOARD_UPDATE messages from WebSocket
  void _listenToLeaderboardUpdates() {
    _messageSubscription?.cancel();
    _messageSubscription = webSocketProvider.messageStream.listen((message) {
      if (message.type != 'LEADERBOARD_UPDATE') {
        return;
      }

      try {
        final payload = message.payload;
        if (payload == null) {
          return;
        }

        final leaderboardData = LeaderboardUpdatePayload.fromJson(payload);
        _leaderboardEntries = _filterEntriesByTrackedRole(
          leaderboardData.entries,
        );
        _lastUpdateTime = leaderboardData.updatedAt;
        _lastChangedUser =
            _isChangedUserForTrackedUser(leaderboardData.changedUser)
            ? leaderboardData.changedUser
            : null;
        _errorMessage = null;

        if (_trackedUserId != null) {
          _applyTrackedUserFromEntries(_leaderboardEntries);
          _scheduleTrackedUserRefresh();
        }

        debugPrint(
          'Leaderboard update received: ${_leaderboardEntries.length} entries, trackedUser=$_trackedUserId, changedUser=${_lastChangedUser?.userId}',
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing leaderboard update: $e');
        _errorMessage = 'Failed to parse leaderboard update: $e';
        notifyListeners();
      }
    });
  }

  void _applyTrackedUserFromEntries(List<LeaderboardEntryDto> entries) {
    final trackedId = _trackedUserId;
    if (trackedId == null) {
      return;
    }

    for (final entry in entries) {
      if (entry.userId == trackedId) {
        _userRankEntry = entry;
        return;
      }
    }
  }

  void _scheduleTrackedUserRefresh() {
    final trackedId = _trackedUserId;
    if (trackedId == null) {
      return;
    }

    _trackedUserRefreshDebounce?.cancel();
    _trackedUserRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
      if (_trackedUserId == trackedId) {
        unawaited(
          fetchUserRank(
            trackedId,
            role: _trackedRole,
            forceRemote: true,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _trackedUserRefreshDebounce?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Get top N entries
  List<LeaderboardEntryDto> getTopEntries(int limit) {
    return _leaderboardEntries.take(limit).toList();
  }

  /// Get the tracked user's rank entry only.
  LeaderboardEntryDto? getUserRank(int userId) {
    if (_trackedUserId != userId) {
      return null;
    }
    return _userRankEntry;
  }

  /// Get last update timestamp formatted
  String get lastUpdateFormatted {
    if (_lastUpdateTime == 0) return 'Never';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(_lastUpdateTime);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  /// Get rank change indicator (↑, ↓, →)
  String getRankChangeIndicator(LeaderboardEntryDto entry) {
    if (entry.rankChangeFromPrevious == null) return '→';
    if (entry.rankChangeFromPrevious! > 0) return '↑';
    if (entry.rankChangeFromPrevious! < 0) return '↓';
    return '→';
  }

  /// Get rank change color (green for up, red for down, gray for no change)
  int getRankChangeColor(LeaderboardEntryDto entry) {
    if (entry.rankChangeFromPrevious == null) return 0xFF808080; // Gray
    if (entry.rankChangeFromPrevious! > 0) return 0xFF4CAF50; // Green
    if (entry.rankChangeFromPrevious! < 0) return 0xFFF44336; // Red
    return 0xFF808080; // Gray
  }

  /// True when this entry matches the latest update for the tracked user.
  bool isEntryRecentlyChanged(LeaderboardEntryDto entry) {
    final changed = _lastChangedUser;
    if (changed == null || entry.userId == null || _trackedUserId == null) {
      return false;
    }
    return changed.userId == _trackedUserId &&
        changed.userId == entry.userId &&
        changed.role.toUpperCase() == entry.role.toUpperCase();
  }

  List<LeaderboardEntryDto> _filterEntriesByTrackedRole(
    List<LeaderboardEntryDto> entries,
  ) {
    final trackedRole = _normalizeRole(_trackedRole);
    if (trackedRole == null || trackedRole.isEmpty) {
      return entries;
    }

    return entries
        .where((entry) => _normalizeRole(entry.role) == trackedRole)
        .toList();
  }

  bool _isChangedUserForTrackedUser(LeaderboardChangedUserPayload? changedUser) {
    if (changedUser == null || _trackedUserId == null) {
      return false;
    }

    if (changedUser.userId != _trackedUserId) {
      return false;
    }

    final trackedRole = _normalizeRole(_trackedRole);
    if (trackedRole == null || trackedRole.isEmpty) {
      return true;
    }

    return _normalizeRole(changedUser.role) == trackedRole;
  }

  String? _normalizeRole(String? role) {
    final value = role?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final normalized = value
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toUpperCase();

    if (normalized == 'BIN_COLLECTOR' || normalized == 'COLLECTION_TEAM') {
      return 'COLLECTOR';
    }
    if (normalized == 'FIELD_STAFF') {
      return 'FIELD_MENTOR';
    }

    return normalized;
  }
}
