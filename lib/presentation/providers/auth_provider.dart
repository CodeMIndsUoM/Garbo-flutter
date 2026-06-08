import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/sources/websocket_service.dart';

/// User entity model for authentication state
class AppUser {
  final int empId;
  final String empName;
  final String email;
  final String role;
  final bool onDuty;
  final double rewardPoints;
  final String? createdAt;
  final String? lastLoginAt;

  AppUser({
    required this.empId,
    required this.empName,
    required this.email,
    required this.role,
    required this.onDuty,
    required this.rewardPoints,
    this.createdAt,
    this.lastLoginAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      empId: json['empId'] as int,
      empName: json['empName'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'COLLECTOR',
      onDuty: json['onDuty'] as bool? ?? false,
      rewardPoints: (json['rewardPoints'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt']?.toString(),
      lastLoginAt: json['lastLoginAt']?.toString(),
    );
  }
}

/// AuthProvider manages login, logout, and WebSocket connection lifecycle
class AuthProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConstants.baseUrl;

  AppUser? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  late WebSocketService _webSocketService;

  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  WebSocketService get webSocketService => _webSocketService;

  AuthProvider() {
    _webSocketService = WebSocketService();
  }

  /// Login with email/username and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. HTTP login request
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final user = AppUser.fromJson(data['data'] as Map<String, dynamic>);
          _currentUser = user;
          _isAuthenticated = true;

          // 2. Connect WebSocket
          await _connectWebSocket(user.empId);

          _setLoading(false);
          notifyListeners();
        } else {
          _setError('Login failed: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _setError(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      _setError('Login error: $e');
    }

    _setLoading(false);
  }

  /// Connect to WebSocket after successful login
  Future<void> _connectWebSocket(int userId) async {
    try {
      await _webSocketService.connect(_baseUrl, userId);
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _setError('Real-time connection failed: $e');
      // Don't fail login just because WebSocket failed
      // User can retry or reconnect will happen automatically
    }
  }

  /// Bridge: set authenticated user from sasindu_dev's direct login response.
  /// This syncs AuthProvider state so collection team providers work.
  void setUserFromLoginResponse(Map<String, dynamic> responseBody) {
    try {
      final empId = responseBody['empId'];
      final empName = responseBody['empName']?.toString() ?? '';
      final email = responseBody['email']?.toString() ?? '';
      final role = responseBody['role']?.toString() ?? 'COLLECTOR';
      final onDuty = responseBody['onDuty'] as bool? ?? false;
      final rewardPoints =
          (responseBody['rewardPoints'] as num?)?.toDouble() ?? 0.0;

      if (empId == null) return;

      _currentUser = AppUser(
        empId: empId is int ? empId : int.tryParse(empId.toString()) ?? 0,
        empName: empName,
        email: email,
        role: role,
        onDuty: onDuty,
        rewardPoints: rewardPoints,
      );
      _isAuthenticated = true;
      _errorMessage = null;

      // Connect WebSocket
      _connectWebSocket(_currentUser!.empId);

      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider bridge error: $e');
    }
  }

  /// Logout and disconnect WebSocket
  Future<void> logout() async {
    await _webSocketService.disconnect();
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Internal helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Internal helper to set error message
  void _setError(String message) {
    _errorMessage = message;
    _setLoading(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
