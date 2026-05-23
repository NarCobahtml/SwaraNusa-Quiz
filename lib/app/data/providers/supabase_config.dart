import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static String get url =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');

  static String get publishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static String get avatarBucket =>
      dotenv.env['SUPABASE_AVATAR_BUCKET'] ??
      const String.fromEnvironment(
        'SUPABASE_AVATAR_BUCKET',
        defaultValue: 'avatars',
      );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;

    await Supabase.initialize(url: url, anonKey: publishableKey);
  }
}
