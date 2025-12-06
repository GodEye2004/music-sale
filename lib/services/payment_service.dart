import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/database_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  // Mock payment process
  Future<Transaction> processPayment({
    required String buyerId,
    required String beatId,
    required String beatTitle,
    required String producerId,
    required double amount,
    required LicenseType licenseType,
  }) async {
    // Create transaction with pending status
    final transaction = Transaction(
      id: _uuid.v4(),
      buyerId: buyerId,
      beatId: beatId,
      beatTitle: beatTitle,
      producerId: producerId,
      amount: amount,
      licenseType: licenseType,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
    );

    await _db.addTransaction(transaction);

    // Simulate payment gateway processing (2 seconds delay)
    await Future.delayed(const Duration(seconds: 2));

    // Mock: Always succeed for now
    // در آینده می‌تونیم چند درصد failure هم اضافه کنیم برای تست

    // Generate mock transaction reference
    final transactionReference =
        'MOCK-${DateTime.now().millisecondsSinceEpoch}';

    // Update transaction to completed
    transaction.status = TransactionStatus.completed;
    transaction.transactionReference = transactionReference;
    await _db.updateTransaction(transaction);

    // Update producer balance
    await _db.updateProducerBalance(producerId, amount);

    // Mark beat as purchased
    await _db.markBeatAsPurchased(beatId);

    // Increment beat downloads
    await _db.incrementBeatDownloads(beatId);

    return transaction;
  }

  // Simulate payment failure (for testing)
  Future<Transaction> processFailedPayment({
    required String buyerId,
    required String beatId,
    required String beatTitle,
    required String producerId,
    required double amount,
    required LicenseType licenseType,
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      buyerId: buyerId,
      beatId: beatId,
      beatTitle: beatTitle,
      producerId: producerId,
      amount: amount,
      licenseType: licenseType,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
    );

    await _db.addTransaction(transaction);

    // Simulate payment gateway processing
    await Future.delayed(const Duration(seconds: 2));

    // Update transaction to failed
    transaction.status = TransactionStatus.failed;
    await _db.updateTransaction(transaction);

    return transaction;
  }

  // Get payment gateway URL (mock)
  String getPaymentGatewayUrl(String transactionId, double amount) {
    // In real app, this would return the actual payment gateway URL
    // For now, just return a mock URL
    return 'https://mock-payment-gateway.ir/pay?transaction=$transactionId&amount=$amount';
  }

  // Verify payment (mock)
  Future<bool> verifyPayment(String transactionId, String authority) async {
    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock: Always return true
    // در واقعیت اینجا با API درگاه پرداخت چک می‌کنیم
    return true;
  }

  // Get transaction by ID
  Transaction? getTransactionById(String transactionId) {
    final transactions = _db.getAllTransactions();
    try {
      return transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  // Calculate platform fee (if needed)
  double calculatePlatformFee(double amount, {double feePercentage = 10.0}) {
    return amount * (feePercentage / 100);
  }

  // Calculate producer earning after platform fee
  double calculateProducerEarning(
    double amount, {
    double feePercentage = 10.0,
  }) {
    return amount - calculatePlatformFee(amount, feePercentage: feePercentage);
  }
}
