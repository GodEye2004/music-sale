import 'package:hive/hive.dart';

part 'settlement_model.g.dart';

@HiveType(typeId: 6)
enum SettlementStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  processing,
  @HiveField(2)
  completed,
  @HiveField(3)
  rejected,
}

@HiveType(typeId: 7)
class Settlement extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String producerId;

  @HiveField(2)
  late String producerName;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late SettlementStatus status;

  @HiveField(5)
  late DateTime requestDate;

  @HiveField(6)
  DateTime? completedDate;

  @HiveField(7)
  late String bankAccountInfo;

  @HiveField(8)
  String? notes;

  Settlement({
    required this.id,
    required this.producerId,
    required this.producerName,
    required this.amount,
    required this.status,
    required this.requestDate,
    this.completedDate,
    required this.bankAccountInfo,
    this.notes,
  });

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} تومان';
  }

  String getStatusName() {
    switch (status) {
      case SettlementStatus.pending:
        return 'در انتظار';
      case SettlementStatus.processing:
        return 'در حال پردازش';
      case SettlementStatus.completed:
        return 'واریز شده';
      case SettlementStatus.rejected:
        return 'رد شده';
    }
  }

  String getStatusColor() {
    switch (status) {
      case SettlementStatus.pending:
        return 'orange';
      case SettlementStatus.processing:
        return 'blue';
      case SettlementStatus.completed:
        return 'green';
      case SettlementStatus.rejected:
        return 'red';
    }
  }
}
