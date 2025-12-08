class Beat {
  final String id;
  final String title;
  final String description;
  final String producerId;
  final String producerName;
  final String genre;
  final String? previewUrl;
  final int bpm;
  final String musicalKey;
  final double price;
  final String previewPath; // URL or Local Path of audio
  final String? fullPath; // URL or Local Path of full audio
  final String? coverImagePath; // URL or Local Path of cover
  final DateTime uploadDate;
  final int downloads;
  final int likes;
  final List<String> tags;
  final bool isExclusive;
  final double? mp3Price;
  final double? wavPrice;
  final double? stemsPrice;
  final double? exclusivePrice;

  Beat({
    required this.id,
    required this.title,
    required this.description,
    required this.producerId,
    required this.producerName,
    required this.genre,
    required this.bpm,
    required this.musicalKey,
    required this.price,
    required this.previewPath,
    this.previewUrl,
    this.fullPath,
    this.coverImagePath,
    required this.uploadDate,
    this.downloads = 0,
    this.likes = 0,
    this.tags = const [],
    this.isExclusive = false,
    this.mp3Price,
    this.wavPrice,
    this.stemsPrice,
    this.exclusivePrice,
  });

  // Factory constructor to create a Beat from JSON (Supabase)
  factory Beat.fromJson(Map<String, dynamic> json) {
    return Beat(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      producerId: json['producer_id'],
      producerName: '', // Will be populated separately or joined
      genre: json['genre'],
      bpm: json['bpm'],
      musicalKey: json['musical_key'],
      price: (json['price'] ?? 0).toDouble(),
      previewPath: json['audio_url'] ?? '',
      fullPath: json['audio_url'],
      coverImagePath: json['cover_url'],
      uploadDate: DateTime.parse(json['created_at']),
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      mp3Price: (json['mp3_price'])?.toDouble(),
      wavPrice: (json['wav_price'])?.toDouble(),
      stemsPrice: (json['stems_price'])?.toDouble(),
      exclusivePrice: (json['exclusive_price'])?.toDouble(),
    );
  }

  // Convert Beat to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'producer_id': producerId,
      'genre': genre,
      'bpm': bpm,
      'musical_key': musicalKey,
      'price': price,
      'audio_url': previewPath,
      'cover_url': coverImagePath,
      'tags': tags,
      'created_at': uploadDate.toIso8601String(),
      'likes': likes,
      'downloads': downloads,
      'mp3_price': mp3Price,
      'wav_price': wavPrice,
      'stems_price': stemsPrice,
      'exclusive_price': exclusivePrice,
    };
  }

  // Helper method to get formatted price
  String getFormattedPrice() {
    return '${price.toStringAsFixed(0)} تومان';
  }
}
