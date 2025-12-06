class AppConstants {
  // App Info
  static const String appName = 'BeatMarket';
  static const String appNameFarsi = 'بازار بیت';
  static const String appVersion = '1.0.0';

  // Genres (ژانرها)
  static const List<String> genres = [
    'Hip-Hop',
    'Trap',
    'Drill',
    'R&B',
    'Pop',
    'Electronic',
    'Lo-Fi',
    'Jazz',
    'Rock',
    'Orchestral',
    'سنتی',
    'فیوژن',
  ];

  // Musical Keys (کلیدهای موسیقی)
  static const List<String> musicalKeys = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
    'Cm',
    'C#m',
    'Dm',
    'D#m',
    'Em',
    'Fm',
    'F#m',
    'Gm',
    'G#m',
    'Am',
    'A#m',
    'Bm',
  ];

  // BPM Range
  static const int minBpm = 60;
  static const int maxBpm = 200;

  // Price Range (تومان)
  static const double minPrice = 0;
  static const double maxPrice = 10000000; // 10 million تومان

  // File Size Limits (MB)
  static const double maxAudioFileSize = 50; // 50 MB
  static const double maxImageFileSize = 5; // 5 MB

  // Audio Preview Duration (seconds)
  static const int previewDurationSeconds = 45;

  // Pagination
  static const int beatsPerPage = 20;

  // Settlement Minimum Amount (تومان)
  static const double minimumSettlementAmount = 100000; // 100K تومان

  // Platform Fee Percentage
  static const double platformFeePercentage = 10.0; // 10%

  // Default Avatar
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  static const String defaultCoverPath = 'assets/images/default_cover.png';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxBioLength = 500;
  static const int maxDescriptionLength = 1000;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
