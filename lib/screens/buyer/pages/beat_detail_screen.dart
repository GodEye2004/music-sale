import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/screens/buyer/controllers/beat_detail_controller.dart';
import 'package:flutter_application_1/screens/buyer/widget/beat_detailes/audio_player_widget.dart';
import 'package:flutter_application_1/screens/buyer/widget/beat_detailes/beat_cover_image.dart';
import 'package:flutter_application_1/screens/buyer/widget/beat_detailes/beat_info_section.dart';
import 'package:flutter_application_1/screens/buyer/widget/beat_detailes/license_selector.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

class BeatDetailScreen extends StatefulWidget {
  final Beat beat;

  const BeatDetailScreen({super.key, required this.beat});

  @override
  State<BeatDetailScreen> createState() => _BeatDetailScreenState();
}

class _BeatDetailScreenState extends State<BeatDetailScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  late BeatDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BeatDetailController(beat: widget.beat);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final isOwnBeat =
        currentUser != null && currentUser.uid == widget.beat.producerId;

    return FutureBuilder<bool>(
      future: currentUser != null
          ? _db.isBeatPurchased(widget.beat.id, currentUser.uid)
          : Future.value(false),
      builder: (context, purchaseSnapshot) {
        final isPurchased = purchaseSnapshot.data ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.beat.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Add to favorites
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BeatCoverWidget(beat: widget.beat),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BeatInfoWidget(beat: widget.beat),

                            const SizedBox(height: 24),

                            if (isOwnBeat)
                              _buildOwnBeatCard()
                            else if (!isPurchased)
                              LicenseSelectionWidget(
                                beat: widget.beat,
                                selectedLicense: _controller.selectedLicense,
                                onLicenseSelected: (license) {
                                  setState(() {
                                    _controller.selectedLicense = license;
                                  });
                                },
                              )
                            else
                              _buildPurchasedCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AudioPlayerWidget(
                controller: _controller,
                showPurchaseButton: !isPurchased && !isOwnBeat,
                onPurchase: () => _controller.purchaseBeat(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOwnBeatCard() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.verified, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بیت شما',
                    style: GoogleFonts.vazirmatn(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'این بیت متعلق به شماست',
                    style: GoogleFonts.vazirmatn(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedCard() {
    return Card(
      color: AppTheme.successColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                'شما این بیت را خریداری کرده‌اید',
                textAlign: TextAlign.right,
                style: GoogleFonts.vazirmatn(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.check_circle, color: AppTheme.successColor),
          ],
        ),
      ),
    );
  }
}
