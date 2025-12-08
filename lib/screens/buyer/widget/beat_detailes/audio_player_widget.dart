import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/screens/buyer/controllers/beat_detail_controller.dart';

class AudioPlayerWidget extends StatelessWidget {
  final BeatDetailController controller;
  final bool showPurchaseButton;
  final VoidCallback? onPurchase;

  const AudioPlayerWidget({
    super.key,
    required this.controller,
    this.showPurchaseButton = false,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress Bar
          ValueListenableBuilder<Duration>(
            valueListenable: controller.positionNotifier,
            builder: (context, position, _) {
              return ValueListenableBuilder<Duration>(
                valueListenable: controller.durationNotifier,
                builder: (context, duration, _) {
                  final maxValue = duration.inSeconds.toDouble();
                  final currentValue = position.inSeconds.toDouble();
                  
                  return Slider(
                    value: currentValue.clamp(0.0, maxValue > 0 ? maxValue : 1.0),
                    max: maxValue > 0 ? maxValue : 1.0,
                    onChanged: (value) async {
                      await controller.seekTo(Duration(seconds: value.toInt()));
                    },
                  );
                },
              );
            },
          ),

          // Time Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<Duration>(
              valueListenable: controller.positionNotifier,
              builder: (context, position, _) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: controller.durationNotifier,
                  builder: (context, duration, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(controller.formatDuration(position)),
                        Text(controller.formatDuration(duration)),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: controller.skipBackward,
              ),
              const SizedBox(width: 20),
              
              // Play/Pause Button
              ValueListenableBuilder<bool>(
                valueListenable: controller.playingNotifier,
                builder: (context, isPlaying, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: controller.loadingNotifier,
                    builder: (context, isLoading, _) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.elevatedShadow,
                        ),
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 32,
                                ),
                                onPressed: controller.togglePlayPause,
                                color: Colors.white,
                              ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: controller.skipForward,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Purchase Button
          if (showPurchaseButton && onPurchase != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.loadingNotifier,
                builder: (context, isLoading, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onPurchase,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.shopping_cart),
                      label: Text(
                        isLoading ? 'در حال پردازش...' : 'خرید بیت',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}