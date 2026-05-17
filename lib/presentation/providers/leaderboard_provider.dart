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
    if (_trackedUserId == userId && _trackedRole == role) {
      return;
    }
    _trackedUserId = userId;
    _trackedRole = role;
    if (userId == null) {
      _userRankEntry = null;
      notifyListeners();
      return;
    }
    loadSnapshot();
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
      final roleQuery =
          _trackedRole != null && _trackedRole!.isNotEmpty
              ? '&role=${Uri.encodeQueryComponent(_trackedRole!)}'
              : '';
      final response = await http
          .get(
            Uri.parse('$_baseUrl/leaderboard/top?limit=$limit$roleQuery'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        _errorMessage =
            'Failed to load leaderboard (${response.statusCode})';
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
      _leaderboardEntries = leaderboardData.entries;
      _lastUpdateTime = leaderboardData.updatedAt;
      _lastChangedUser = leaderboardData.changedUser;
      _errorMessage = null;
      if (_trackedUserId != null) {
        await fetchUserRank(_trackedUserId!, role: _trackedRole);
      } else {
        notifyListeners();
      }
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
  Future<void> fetchUserRank(int userId, {String? role}) async {
    if (_isLoadingUserRank) {
      return;
    }

    _isLoadingUserRank = true;
    try {
      final headers = await _buildAuthHeaders();
      final roleQuery =
          role != null && role.isNotEmpty
              ? '?role=${Uri.encodeQueryComponent(role)}'
              : '';
      final response = await http
          .get(
            Uri.parse('$_baseUrl/leaderboard/user/$userId$roleQuery'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

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
      _userRankEntry = null;
    } finally {
      _isLoadingUserRank = false;
    }
  }

  /// Listen to LEADERBOARD_UPDATE messages from WebSocket
  void _listenToLeaderboardUpdates() {
    _messageSubscription?.cancel();
    _messageSubscription = webSocketProvider.messageStream.listen((message) {
      if (message.type == 'LEADERBOARD_UPDATE') {
        try {
          // Parse the leaderboard update payload
          final payload = message.payload;
          if (payload != null) {
            final leaderboardData = LeaderboardUpdatePayload.fromJson(
              payload,
            );
            _leaderboardEntries = leaderboardData.entries;
            _lastUpdateTime = leaderboardData.updatedAt;
            _lastChangedUser = leaderboardData.changedUser;
            _errorMessage = null;

            debugPrint(
              'Leaderboard update received: ${_leaderboardEntries.length} entries, changedUser=${_lastChangedUser?.userId}, rankDelta=${_lastChangedUser?.rankDelta}, scoreDelta=${_lastChangedUser?.scoreDelta}',
            );
            if (_trackedUserId != null) {
              unawaited(loadSnapshot());
            } else {
              notifyListeners();
            }
          }
        } catch (e) {
          debugPrint('Error parsing leaderboard update: $e');
          _errorMessage = 'Failed to parse leaderboard update: $e';
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
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

  /// Get user's rank (returns null if not in top 10)
  LeaderboardEntryDto? getUserRank(int userId) {
    if (_userRankEntry?.userId == userId) {
      return _userRankEntry;
    }
    try {
      return _leaderboardEntries.firstWhere(
        (entry) => entry.userId == userId,
      );
    } catch (e) {
      return null;
    }
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

  /// True when this entry matches the latest user that triggered a realtime update.
  bool isEntryRecentlyChanged(LeaderboardEntryDto entry) {
    final changed = _lastChangedUser;
    if (changed == null || entry.userId == null) {
      return false;
    }
    return changed.userId == entry.userId &&
        changed.role.toUpperCase() == entry.role.toUpperCase();
  }
}
