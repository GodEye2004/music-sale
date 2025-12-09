import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';

class BeatInfoWidget extends StatelessWidget {
  final Beat beat;

  const BeatInfoWidget({
    super.key,
    required this.beat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Align(
          alignment: .centerRight,
          child: Text(
            beat.title,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),

        const SizedBox(height: 8),

        // Producer
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.person,
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              beat.producerName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Info Cards
        Row(
          children: [
            Expanded(
              child: InfoCard(
                icon: Icons.speed,
                label: 'BPM',
                value: '${beat.bpm}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCard(
                icon: Icons.music_note,
                label: 'Key',
                value: beat.musicalKey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCard(
                icon: Icons.category,
                label: 'Genre',
                value: beat.genre,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Description
        Align(
          alignment: .centerRight,
          child: Text(
            'توضیحات',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: .centerRight,
          child: Text(
            beat.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}