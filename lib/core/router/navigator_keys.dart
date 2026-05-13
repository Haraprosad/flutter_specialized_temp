import 'package:flutter/material.dart';

@immutable
class NavigatorKeys {
  const NavigatorKeys._();
  static final rootNavigator = GlobalKey<NavigatorState>();
  static final shellNavigator = GlobalKey<NavigatorState>();
}
