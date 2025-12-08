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
    // Simulate payment gateway processing (2 seconds delay)
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock transaction reference
    final transactionId = _uuid.v4();
    final transactionRef = 'MOCK-${DateTime.now().millisecondsSinceEpoch}';

    // Create completed transaction
    final transaction = Transaction(
      id: transactionId,
      beatId: beatId,
      beatTitle: beatTitle,
      buyerId: buyerId,
      producerId: producerId,
      licenseType: licenseType,
      amount: amount,
      status: TransactionStatus.completed,
      timestamp: DateTime.now(),
      transactionReference: transactionRef,
    );

    // Store transaction in database
    await _db.addTransaction(transaction);

    // Update producer balance
    await _db.updateProducerBalance(producerId, amount);

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
    await Future.delayed(const Duration(seconds: 2));

    final transaction = Transaction(
      id: _uuid.v4(),
      beatId: beatId,
      beatTitle: beatTitle,
      buyerId: buyerId,
      producerId: producerId,
      licenseType: licenseType,
      amount: amount,
      status: TransactionStatus.failed,
      timestamp: DateTime.now(), transactionReference: '',
    );

    await _db.addTransaction(transaction);

    return transaction;
  }

  // Get payment gateway URL (mock)
  String getPaymentGatewayUrl(String transactionId, double amount) {
    return 'https://mock-payment-gateway.ir/pay?transaction=$transactionId&amount=$amount';
  }

  // Verify payment (mock)
  Future<bool> verifyPayment(String transactionId, String authority) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
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
