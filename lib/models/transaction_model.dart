enum LicenseType { mp3, wav, stems, exclusive }

enum TransactionStatus { pending, completed, failed }

class Transaction {
  final String id;
  final String beatId;
  final String beatTitle;
  final String buyerId;
  final String producerId;
  final LicenseType licenseType;
  final double amount;
  final TransactionStatus status;
  final DateTime timestamp; // Originally createdAt
  final String transactionReference;

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
    required this.transactionReference,
  });

  // Factory constructor for Supabase
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      beatId: json['beat_id'],
      // beatTitle must be joined or fetched separately, usually not in transactions table directly
      // Assuming we join beats table or store title for history
      beatTitle: json['beats'] != null
          ? json['beats']['title']
          : 'Unknown Beat',
      buyerId: json['buyer_id'],
      producerId: json['producer_id'],
      licenseType: _parseLicenseType(json['license_type']),
      amount: (json['amount'] as num).toDouble(),
      status: _parseStatus(json['status']),
      timestamp: DateTime.parse(json['created_at']),
      transactionReference: json['id'], // using ID as reference for now
    );
  }

  String getLicenseTypeName() {
    switch (licenseType) {
      case LicenseType.mp3:
        return 'MP3 Lease';
      case LicenseType.wav:
        return 'WAV Lease';
      case LicenseType.stems:
        return 'Trackout / Stems';
      case LicenseType.exclusive:
        return 'Exclusive Rights';
    }
  }

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} تومان';
  }

  static LicenseType _parseLicenseType(String type) {
    switch (type) {
      case 'wav':
        return LicenseType.wav;
      case 'stems':
        return LicenseType.stems;
      case 'exclusive':
        return LicenseType.exclusive;
      default:
        return LicenseType.mp3;
    }
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }
}
