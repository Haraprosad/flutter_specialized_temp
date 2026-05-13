import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [widget] with [MaterialApp] and [ScreenUtilInit] so widget tests
/// have a minimal but realistic rendering context.
///
/// Pass `providers` to inject any BLoC/Cubit instances the widget under test
/// needs. Example:
/// ```dart
/// await tester.pumpApp(
///   MyScreen(),
///   providers: [BlocProvider<MyBloc>(create: (_) => MockMyBloc())],
/// );
/// ```
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<BlocProvider> providers = const [],
    ThemeData? theme,
  }) async {
    var child = widget;

    if (providers.isNotEmpty) {
      child = MultiBlocProvider(providers: providers, child: child);
    }

    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(theme: theme ?? ThemeData.light(), home: child),
      ),
    );
  }
}
