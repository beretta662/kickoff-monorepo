import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Point d'accès unique au client Supabase, partagé par les deux apps.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Rafraîchit la session si le jeton d'accès est expiré. À appeler
  /// juste avant une série de requêtes au démarrage, pour ne pas les
  /// envoyer avec un jeton périmé.
  static Future<void> ensureFreshSession() async {
    final session = client.auth.currentSession;
    if (session != null && session.isExpired) {
      await client.auth.refreshSession();
    }
  }
}