import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

final class SupabaseClientConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.get(AppConstants.supabaseUrlKey),
      anonKey: dotenv.get(AppConstants.supabaseAnonKey),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
