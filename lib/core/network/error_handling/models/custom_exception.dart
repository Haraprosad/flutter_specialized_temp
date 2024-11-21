import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';

class CustomException implements Exception {
  final CustomErrorType type;
  final dynamic originalError; 


  CustomException({required this.type, this.originalError});

  @override
  String toString() => 'CustomException: $type - $originalError'; // Helpful for debugging
}
