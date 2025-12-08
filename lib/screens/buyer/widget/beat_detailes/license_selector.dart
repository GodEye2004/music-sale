import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/models/transaction_model.dart';

class LicenseSelectionWidget extends StatelessWidget {
  final Beat beat;
  final LicenseType selectedLicense;
  final Function(LicenseType) onLicenseSelected;

  const LicenseSelectionWidget({
    super.key,
    required this.beat,
    required this.selectedLicense,
    required this.onLicenseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'انتخاب لایسنس:',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),

        if (beat.mp3Price != null)
          LicenseOptionCard(
            type: LicenseType.mp3,
            name: 'MP3',
            price: beat.mp3Price!,
            isSelected: selectedLicense == LicenseType.mp3,
            onTap: () => onLicenseSelected(LicenseType.mp3),
          ),

        if (beat.wavPrice != null)
          LicenseOptionCard(
            type: LicenseType.wav,
            name: 'WAV',
            price: beat.wavPrice!,
            isSelected: selectedLicense == LicenseType.wav,
            onTap: () => onLicenseSelected(LicenseType.wav),
          ),

        if (beat.stemsPrice != null)
          LicenseOptionCard(
            type: LicenseType.stems,
            name: 'Stems',
            price: beat.stemsPrice!,
            isSelected: selectedLicense == LicenseType.stems,
            onTap: () => onLicenseSelected(LicenseType.stems),
          ),

        if (beat.exclusivePrice != null)
          LicenseOptionCard(
            type: LicenseType.exclusive,
            name: 'انحصاری',
            price: beat.exclusivePrice!,
            isSelected: selectedLicense == LicenseType.exclusive,
            onTap: () => onLicenseSelected(LicenseType.exclusive),
          ),
      ],
    );
  }
}

class LicenseOptionCard extends StatelessWidget {
  final LicenseType type;
  final String name;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const LicenseOptionCard({
    super.key,
    required this.type,
    required this.name,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                '${price.toStringAsFixed(0)} تومان',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}