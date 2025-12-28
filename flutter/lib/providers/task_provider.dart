import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final String baseUrl = '/api/tasks'; // Use relative URL for production

  List<Task> _tasks = [];
  bool _isLoading = false;
  late Dio _dio;
  bool _isOnline = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  TaskProvider() {
    _dio = Dio();

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<void> fetchTasks() async {
    if (!_isOnline) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _tasks = data.map((json) => Task.fromJson(json)).toList();
      } else {
        print('Failed to load tasks: ${response.statusCode}');
        _tasks = []; // Clear tasks on error
      }
    } catch (error) {
      print('Error fetching tasks: $error');
      _tasks = []; // Clear tasks on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'assigned_to': assignedTo,
          'due_date': dueDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final newTask = Task.fromJson(json.decode(response.body));
        _tasks.insert(0, newTask);
        notifyListeners();
      } else {
        throw Exception('Failed to add task');
      }
    } catch (error) {
      print('Error adding task: $error');
      rethrow;
    }
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
          if (assignedTo != null) 'assigned_to': assignedTo,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final updatedTask = Task.fromJson(json.decode(response.body));
        final index = _tasks.indexWhere((task) => task.id == id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update task');
      }
    } catch (error) {
      print('Error updating task: $error');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 204) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      print('Error deleting task: $error');
      rethrow;
    }
  }
}
