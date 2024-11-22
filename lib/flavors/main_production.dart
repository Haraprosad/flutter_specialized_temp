import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import '../main.dart';
import 'env_config.dart';
import 'environment.dart';

void main() async{
  await dotenv.load(fileName: EnvConstants.envProduction);
  
  EnvConfig.instantiate(
    appName: 'Production App', 
    baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!, 
    env: Env.PRODUCTION 
  );

  await runMainApp();
}
