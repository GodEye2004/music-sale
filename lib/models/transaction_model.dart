import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
enum LicenseType {
  @HiveField(0)
  mp3,
  @HiveField(1)
  wav,
  @HiveField(2)
  stems,
  @HiveField(3)
  exclusive,
}

@HiveType(typeId: 4)
enum TransactionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  failed,
}

@HiveType(typeId: 5)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String buyerId;

  @HiveField(2)
  late String beatId;

  @HiveField(3)
  late String beatTitle;

  @HiveField(4)
  late String producerId;

  @HiveField(5)
  late double amount;

  @HiveField(6)
  late LicenseType licenseType;

  @HiveField(7)
  late TransactionStatus status;

  @HiveField(8)
  late DateTime timestamp;

  @HiveField(9)
  String? transactionReference; // Mock payment reference

  Transaction({
    required this.id,
    required this.buyerId,
    required this.beatId,
    required this.beatTitle,
    required this.producerId,
    required this.amount,
    required this.licenseType,
    required this.status,
    required this.timestamp,
    this.transactionReference,
  });

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} تومان';
  }

  String getLicenseTypeName() {
    switch (licenseType) {
      case LicenseType.mp3:
        return 'MP3';
      case LicenseType.wav:
        return 'WAV';
      case LicenseType.stems:
        return 'Stems';
      case LicenseType.exclusive:
        return 'انحصاری';
    }
  }

  String getStatusName() {
    switch (status) {
      case TransactionStatus.pending:
        return 'در انتظار';
      case TransactionStatus.completed:
        return 'موفق';
      case TransactionStatus.failed:
        return 'ناموفق';
    }
  }
}
