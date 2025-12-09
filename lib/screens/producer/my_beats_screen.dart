import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/screens/producer/upload_beat_screen.dart';
import 'package:flutter_application_1/widgets/beat_card.dart';
import 'package:flutter_application_1/screens/buyer/pages/beat_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBeatsScreen extends StatefulWidget {
  const MyBeatsScreen({super.key});

  @override
  State<MyBeatsScreen> createState() => _MyBeatsScreenState();
}

class _MyBeatsScreenState extends State<MyBeatsScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  List<Beat> _myBeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyBeats();
  }

  Future<void> _loadMyBeats() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final beats = await _db.getBeatsByProducer(currentUser.uid);
        setState(() {
          _myBeats = beats;
        });
      }
    } catch (e) {
      print('Error loading beats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshBeats() async {
    await _loadMyBeats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بیت‌های من',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshBeats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myBeats.isEmpty
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
                    'هنوز بیتی آپلود نکرده‌اید',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UploadBeatScreen(),
                        ),
                      );
                      if (result == true) {
                        _refreshBeats();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'آپلود اولین بیت',
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshBeats,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _myBeats.length,
                itemBuilder: (context, index) {
                  return BeatCard(
                    beat: _myBeats[index],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BeatDetailScreen(beat: _myBeats[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: _myBeats.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadBeatScreen()),
                );
                if (result == true) {
                  _refreshBeats();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                'بیت جدید',
                style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
