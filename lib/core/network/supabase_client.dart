import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

final class SupabaseClientConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: dotenv.get(AppConstants.supabaseUrlKey),
        anonKey: dotenv.get(AppConstants.supabaseAnonKey),
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase no está inicializado. Verifique el archivo .env');
    }
    return Supabase.instance.client;
  }
}
