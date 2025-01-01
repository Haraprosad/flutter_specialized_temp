import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import 'package:flutter_specialized_temp/flavors/app_initializer.dart';
import 'package:flutter_specialized_temp/flavors/environment.dart';

void main() async {
  await initializeApp(
    EnvConstants.envDevelopment,
    'Development App',
    Env.DEVELOPMENT,
  );
}