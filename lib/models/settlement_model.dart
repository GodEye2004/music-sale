enum SettlementStatus { pending, processing, completed, rejected }

class Settlement {
  final String id;
  final String producerId;
  final String producerName;
  final double amount;
  final SettlementStatus status;
  final DateTime requestDate;
  final DateTime? completedDate;
  final String bankAccountInfo;
  final String? notes;

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

  // Changed to return int/Color compatible value if needed, or kept as logic helper
  // For now returning String to match previous logic, but ideally should return Color object
  String getStatusColorName() {
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
