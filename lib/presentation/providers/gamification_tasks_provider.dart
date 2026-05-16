import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

/// GamificationTasksProvider manages user's gamification tasks and achievements
class GamificationTasksProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConstants.baseUrl;

  List<UserTaskProgress> _userTasks = [];
  List<GamificationTaskDto> _availableTasks = [];
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
      _taskProgressSubscription;
  int? _activeUserId;

  List<UserTaskProgress> get userTasks => _userTasks;
  List<GamificationTaskDto> get availableTasks => _availableTasks;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Getters for separated tasks
  List<UserTaskProgress> get completedTasks =>
      _userTasks.where((task) => task.isCompleted).toList();

  List<UserTaskProgress> get ongoingTasks =>
      _userTasks.where((task) => !task.isCompleted).toList();

  int get totalCompleted => completedTasks.length;
  int get totalTasks => _userTasks.length;

  /// Load user's gamification tasks and progress
  Future<void> loadUserTasks(int userId) async {
    _activeUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _buildAuthHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/$userId/gamification-tasks'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _userTasks = [];
        _errorMessage = 'Failed to load tasks';
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] is! List) {
        _userTasks = [];
        _errorMessage = body['message']?.toString() ?? 'Failed to load tasks';
        return;
      }

      final rawList = body['data'] as List<dynamic>;
      _userTasks = rawList
          .whereType<Map<String, dynamic>>()
          .map(UserTaskProgress.fromJson)
          .toList();

      _errorMessage = null;
    } catch (e) {
      _userTasks = [];
      _errorMessage = 'Failed to load tasks: $e';
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void attachWebSocket(WebSocketProvider webSocketProvider) {
    _taskProgressSubscription?.cancel();
    _taskProgressSubscription = webSocketProvider.messageStream.listen((message) {
      if (message.type != 'TASK_PROGRESS_UPDATE') {
        return;
      }
      final payload = message.payload;
      if (payload == null) {
        return;
      }

      try {
        final update = TaskProgressUpdatePayload.fromJson(payload);
        if (_activeUserId != null && update.userId != _activeUserId) {
          return;
        }

        for (final item in update.tasks) {
          final index = _userTasks.indexWhere((task) => task.taskId == item.taskId);
          final mapped = UserTaskProgress(
            userId: update.userId,
            taskId: item.taskId,
            taskCode: item.taskCode,
            taskTitle: item.taskTitle,
            taskDescription: item.taskDescription,
            currentProgress: item.currentProgress,
            targetProgress: item.targetProgress,
            isCompleted: item.isCompleted,
            completedAt: item.completedAt,
            pointsEarned: item.pointsEarned,
          );

          if (index == -1) {
            _userTasks.add(mapped);
          } else {
            _userTasks[index] = mapped;
          }
        }

        _userTasks.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
            return a.taskTitle.toLowerCase().compareTo(b.taskTitle.toLowerCase());
          }
          return a.isCompleted ? -1 : 1;
        });
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to parse TASK_PROGRESS_UPDATE: $e');
      }
    });
  }

  /// Load available gamification tasks for the user's role
  Future<void> loadAvailableTasks(String role) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/admins/gamification/tasks/active?role=$role'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _availableTasks = [];
        _errorMessage = 'Failed to load available tasks';
        notifyListeners();
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] is! List) {
        _availableTasks = [];
        _errorMessage = body['message']?.toString() ?? 'Failed to load available tasks';
        notifyListeners();
        return;
      }

      final rawList = body['data'] as List<dynamic>;
      _availableTasks = rawList
          .whereType<Map<String, dynamic>>()
          .map(GamificationTaskDto.fromJson)
          .toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _availableTasks = [];
      _errorMessage = 'Failed to load available tasks: $e';
      debugPrint('Error loading available tasks: $e');
      notifyListeners();
    }
  }

  /// Update a specific task's progress (typically called when task is completed)
  void updateTaskProgress(int taskId, double newProgress, {bool? isCompleted}) {
    final index = _userTasks.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      final task = _userTasks[index];
      _userTasks[index] = UserTaskProgress(
        userId: task.userId,
        taskId: task.taskId,
        taskCode: task.taskCode,
        taskTitle: task.taskTitle,
        taskDescription: task.taskDescription,
        currentProgress: newProgress,
        targetProgress: task.targetProgress,
        isCompleted: isCompleted ?? (newProgress >= task.targetProgress),
        completedAt: (isCompleted ?? (newProgress >= task.targetProgress))
            ? DateTime.now().toIso8601String()
            : task.completedAt,
        pointsEarned: task.pointsEarned,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _taskProgressSubscription?.cancel();
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
}
