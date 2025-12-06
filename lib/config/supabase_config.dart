class SupabaseConfig {
  // Supabase credentials
  static const String supabaseUrl = 'https://jbjxcnftvfjzivedikha.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpianhjbmZ0dmZqeml2ZWRpa2hhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwNTM2ODEsImV4cCI6MjA4MDYyOTY4MX0.TwhDr8Zm_00ggFrMGNmduia1PtiRY0AfInwUFy5dBUE';

  // Storage buckets
  static const String beatAudioBucket = 'beats-audio';
  static const String beatCoversBucket = 'beats-covers';

  // Table names
  static const String usersTable = 'users';
  static const String beatsTable = 'beats';
  static const String transactionsTable = 'transactions';
  static const String settlementsTable = 'settlements';
}
