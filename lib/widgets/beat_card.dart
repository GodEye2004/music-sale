import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/screens/buyer/pages/beat_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BeatCard extends StatelessWidget {
  final Beat beat;
  final VoidCallback? onTap;

  const BeatCard({super.key, required this.beat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BeatDetailScreen(beat: beat)),
            );
          },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Placeholder Icon
                    const Center(
                      child: Icon(
                        Icons.music_note,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),

                    // Play Button Overlay
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.darkOverlayGradient,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Like Button (سمت چپ)
                            Icon(
                              beat.likes > 0
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: beat.likes > 0
                                  ? AppTheme.secondaryColor
                                  : Colors.white,
                            ),

                            // BPM Badge (سمت راست)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${beat.bpm} BPM',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Beat Info - همه متن‌ها راست‌چین
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title
                  Text(
                    beat.title,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),

                  const SizedBox(height: 4),

                  // Producer Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          beat.producerName,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Genre and Key
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Key
                      Text(
                        beat.musicalKey,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHintColor,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Genre
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          beat.genre,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    beat.getFormattedPrice(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.successColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
