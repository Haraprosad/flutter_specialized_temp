import 'package:flutter/foundation.dart';

@immutable
class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  
  // Main Routes with Bottom Navigation
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Nested Routes
  static const String taskDetails = 'details/:taskId';
  static const String subTasks = 'sub-tasks/:taskId';
  static const String editTask = 'edit/:taskId';
  
  // Profile Routes
  static const String editProfile = 'edit';
  static const String preferences = 'preferences';
  
  const RoutePaths._();
}