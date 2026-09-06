import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Point d'accès unique au client Supabase, partagé par les deux apps.
///
/// Utilisation :
/// - Au démarrage : `await SupabaseService.initialize();`
/// - Partout ailleurs : `SupabaseService.client.auth...` ou `.from('table')...`
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}