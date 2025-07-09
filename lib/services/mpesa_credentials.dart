import 'package:flutter_dotenv/flutter_dotenv.dart';

class MpesaCredentials {
  static String get consumerKey => dotenv.env['MPESA_CONSUMER_KEY'] ?? '';
  static String get consumerSecret => dotenv.env['MPESA_CONSUMER_SECRET'] ?? '';
  static String get shortCode => dotenv.env['MPESA_SHORTCODE'] ?? '';
  static String get passKey => dotenv.env['MPESA_PASSKEY'] ?? '';
  static String get callbackUrl => dotenv.env['MPESA_CALLBACK_URL'] ?? '';
}
