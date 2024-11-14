import 'package:flutter/foundation.dart';

@immutable
class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  
  // Main Routes
  static const String home = 'home';
  static const String tasks = 'tasks';
  static const String profile = 'profile';
  static const String settings = 'settings';
  
  // Nested Routes
  static const String taskDetails = 'taskDetails';
  static const String subTasks = 'subTasks';
  static const String editTask = 'editTask';
  static const String notifications = 'notifications';
  
  // Profile Routes
  static const String editProfile = 'editProfile';
  static const String preferences = 'preferences';
  
  const RouteNames._();
}