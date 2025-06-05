import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get rapidApiKey => dotenv.env['RAPIDAPI_KEY'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
}
