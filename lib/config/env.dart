
import './env.dev.dart';
import './env.test.dart';
import './env.uat.dart';
import './env.prod.dart';

enum Environment {
  dev,
  test,
  uat,
  prod
}

class EnvConfig {
  final String baseUrl;
  final String envName;
  const EnvConfig({
    required this.baseUrl,
    required this.envName
  });
}

class Env {
  static late EnvConfig current;
  static void setEnv(Environment env) {
    switch(env) {
      case Environment.dev:
        current = devConfig;
        break;
      case Environment.test:
        current = testConfig;
        break;
      case Environment.uat:
        current = uatConfig;
        break;
      case Environment.prod:
        current = prodConfig;
        break;
    }
  }
}

class Envv2 {
  static late EnvConfig current;
  static final flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static final baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'https://');
  
}