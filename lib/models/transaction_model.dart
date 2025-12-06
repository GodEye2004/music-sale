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
  final String id;

  @HiveField(1)
  final String beatId;

  @HiveField(2)
  final String beatTitle;

  @HiveField(3)
  final String buyerId;

  @HiveField(4)
  final String producerId;

  @HiveField(5)
  final LicenseType licenseType;

  @HiveField(6)
  final double amount;

  @HiveField(7)
  final TransactionStatus status;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final String? transactionReference;

  Transaction({
    required this.id,
    required this.beatId,
    required this.beatTitle,
    required this.buyerId,
    required this.producerId,
    required this.licenseType,
    required this.amount,
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
