import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';
