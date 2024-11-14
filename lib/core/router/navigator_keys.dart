import 'package:flutter/material.dart';

@immutable
class NavigatorKeys {
  static final rootNavigator = GlobalKey<NavigatorState>();
  static final shellNavigator = GlobalKey<NavigatorState>();
  
  const NavigatorKeys._();
}