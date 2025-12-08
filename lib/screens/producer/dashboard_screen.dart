import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/screens/producer/upload_beat_screen.dart';
import 'package:flutter_application_1/screens/producer/my_beats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});

  @override
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  UserModel? _currentUser;
  UserRole? _useRole;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Future<void> _initData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final roleString = prefs.getString('user_role');
  //   final role = roleString != null
  //       ? UserRole.values.firstWhere((r) => r.name == roleString)
  //       : UserRole.buyer;

  //   final user = await _auth.fetchCurrentUser();

  //   setState(() {
  //     _useRole = role;
  //     _currentUser = user;
  //     _isLoading = false;
  //   });
  // }

  Future<void> _initData() async {
    final user = AuthService().currentUser;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('داشبورد')),
        body: const Center(child: Text('خطا در بارگذاری کاربر')),
      );
    }

    if (_currentUser!.role != UserRole.producer) {
      return Scaffold(
        appBar: AppBar(title: const Text('داشبورد')),
        body: const Center(child: Text('شما دسترسی به این بخش ندارید')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد پرودیوسر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyBeatsScreen()));
            },
            tooltip: 'بیت‌های من',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'کل درآمد',
                    value: _currentUser!.getFormattedEarnings(),
                    icon: Icons.attach_money,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'فروش‌ها',
                    value: '${_currentUser!.totalSales}',
                    icon: Icons.shopping_cart,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settlement Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صفحه تسویه حساب به زودی...')),
                );
              },
              icon: const Icon(Icons.payments),
              label: const Text('درخواست تسویه حساب'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Sales
            Text(
              'آخرین فروش‌ها',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 12),

            _buildRecentSales(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const UploadBeatScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('بیت جدید'),
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'آپلود بیت جدید',
      ),
    );
  }

  Widget _buildRecentSales() {
    return FutureBuilder<List<Transaction>>(
      future: _db.getTransactionsByProducer(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: AppTheme.textHintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هنوز فروشی نداشته‌اید',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: transactions.take(5).map((trans) {
            return FutureBuilder<UserModel?>(
              future: _db.getUserById(trans.buyerId),
              builder: (context, userSnap) {
                final buyerName = userSnap.data?.displayName ?? 'کاربر ناشناس';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.successColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(trans.beatTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('خریدار: $buyerName'),
                        Text('لایسنس: ${trans.getLicenseTypeName()}'),
                      ],
                    ),
                    trailing: Text(
                      trans.getFormattedAmount(),
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
