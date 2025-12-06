import 'package:hive/hive.dart';

part 'beat_model.g.dart';

@HiveType(typeId: 0)
class Beat extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String producerId;

  @HiveField(4)
  late String producerName;

  @HiveField(5)
  late String genre;

  @HiveField(6)
  late int bpm;

  @HiveField(7)
  late String musicalKey;

  @HiveField(8)
  late double price;

  @HiveField(9)
  late String previewPath; // Local file path for preview

  @HiveField(10)
  String? fullPath; // Local file path for full version

  @HiveField(11)
  String? coverImagePath;

  @HiveField(12)
  late DateTime uploadDate;

  @HiveField(13)
  int downloads;

  @HiveField(14)
  int likes;

  @HiveField(15)
  List<String> tags;

  @HiveField(16)
  bool isExclusive;

  @HiveField(17)
  double? mp3Price;

  @HiveField(18)
  double? wavPrice;

  @HiveField(19)
  double? stemsPrice;

  @HiveField(20)
  double? exclusivePrice;

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

  // Helper method to get formatted price
  String getFormattedPrice() {
    return '${price.toStringAsFixed(0)} تومان';
  }

  // Helper to check if user has liked
  bool isLikedBy(String userId) {
    // This will be implemented with a separate likes collection
    return false;
  }
}
