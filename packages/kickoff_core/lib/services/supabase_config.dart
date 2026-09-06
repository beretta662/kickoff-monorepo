/// Clés du projet Supabase. L'anon key est volontairement publique
/// (elle est faite pour être visible côté client) : la vraie protection
/// des données se fait via les policies RLS côté base, pas en cachant
/// cette clé. Pas de souci à ce qu'elle soit sur GitHub.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://kohfqzweecdhjeodfsct.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvaGZxendlZWNkaGplb2Rmc2N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MDM2MTUsImV4cCI6MjEwNDE3OTYxNX0.y9xzV5rOb9FA8HuoUIgSHfSBBwIiJueRBdLH4fsapYE';
}