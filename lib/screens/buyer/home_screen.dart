import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/producer/dashboard_screen.dart';
import 'package:flutter_application_1/widgets/beat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  List<Beat> _beats = [];
  List<Beat> _filteredBeats = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBeats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBeats() async {
    setState(() => _isLoading = true);

    try {
      final beats = await _db.getAllBeatsAsync();
      setState(() {
        _beats = beats;
        _filteredBeats = beats;
      });
    } catch (e) {
      print('Error loading beats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchBeats(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredBeats = _beats;
      });
    } else {
      final results = await _db.searchBeats(query);
      setState(() {
        _filteredBeats = results;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _navigateToProducerDashboard() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProducerDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final isProducer = currentUser?.isProducer() ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بازار بیت'),
        actions: [
          if (isProducer)
            IconButton(
              icon: const Icon(Icons.dashboard_outlined),
              onPressed: _navigateToProducerDashboard,
              tooltip: 'داشبورد پرودیوسر',
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _searchBeats,
              decoration: InputDecoration(
                hintText: 'جستجوی بیت...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchBeats('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Welcome Message
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سلام ${currentUser.displayName}!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          isProducer ? 'پرودیوسر' : 'خریدار',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Beats Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadBeats,
                    child: _filteredBeats.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_off,
                                  size: 80,
                                  color: AppTheme.textHintColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'هیچ بیتی یافت نشد',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'برای به‌روزرسانی کشیده و رها کنید',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _filteredBeats.length,
                            itemBuilder: (context, index) {
                              return BeatCard(beat: _filteredBeats[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
