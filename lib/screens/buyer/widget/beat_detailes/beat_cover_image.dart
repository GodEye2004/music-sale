import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';

class BeatCoverWidget extends StatelessWidget {
  final Beat beat;

  const BeatCoverWidget({
    super.key,
    required this.beat,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: beat.coverImagePath != null
            ? Image.file(
                File(beat.coverImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.music_note,
        size: 100,
        color: Colors.white70,
      ),
    );
  }
}