import 'environment.dart';

class EnvConfig {
  late final String appName;
  late final String baseUrl;
  late final Env env;

  EnvConfig._internal();
  static final EnvConfig instance = EnvConfig._internal();

  bool _lock = false;
  factory EnvConfig.instantiate({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    if (instance._lock) return instance;

    instance.appName = appName;
    instance.baseUrl = baseUrl;
    instance.env = env;
    instance._lock = true;
    
    return instance;
  }
}
