import 'package:flutter_specialized_temp/core/di/injection.config.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(generateForDir: ['lib', 'test'])
Future<void> configureDependencies() async {
  try {
    await sl.init();
    AppLogger.i(message: '✅ Dependencies configured successfully');
  } catch (e) {
    AppLogger.e(message: '❌ Failed to configure dependencies: $e');
    rethrow;
  }
}
