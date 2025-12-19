
import 'env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final uatConfig = EnvConfig(
  baseUrl: dotenv.get('BASE_URL'),
  envName: dotenv.get('ENV_NAME'),
  sucessCode: int.parse(dotenv.get('SUCCESS_CODE')),
);
