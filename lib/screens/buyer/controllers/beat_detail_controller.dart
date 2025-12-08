import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BeatDetailController {
  final Beat beat;
  final AudioPlayer audioPlayer = AudioPlayer();
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final PaymentService _payment = PaymentService();

  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  LicenseType selectedLicense = LicenseType.mp3;

  late StreamSubscription<PlayerState> _playerStateSub;
  late StreamSubscription<Duration?> _durationSub;
  late StreamSubscription<Duration> _positionSub;

  final ValueNotifier<bool> playingNotifier = ValueNotifier(false);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  BeatDetailController({required this.beat});

  Future<void> initialize() async {
    _setupListeners();
    await _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      loadingNotifier.value = true;
      
      final response = await Supabase.instance.client
          .from('beats')
          .select('preview_path')
          .eq('id', beat.id)
          .maybeSingle();

      if (response == null) {
        print('Beat not found in database');
        return;
      }

      final filePath = (response as Map<String, dynamic>)['preview_path'] as String?;
      
      if (filePath == null || filePath.isEmpty) {
        print('Preview path is empty');
        return;
      }

      // حذف اسلش اول اگر وجود داشت
      final cleanPath = filePath.startsWith('/') 
          ? filePath.substring(1) 
          : filePath;

      // دریافت URL عمومی
      final previewUrl = Supabase.instance.client.storage
          .from('beats')
          .getPublicUrl(cleanPath);

      print('🎵 Loading audio from: $previewUrl');

      // تنظیم audio source با retry و error handling
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(previewUrl),
          tag: {'title': beat.title, 'artist': beat.producerName},
        ),
      );

      print('✅ Audio loaded successfully');
      
      // بررسی duration
      final audioDuration = audioPlayer.duration;
      if (audioDuration != null) {
        durationNotifier.value = audioDuration;
        print('🎵 Duration: ${_formatDuration(audioDuration)}');
      }
      
    } catch (e, st) {
      print('❌ Error loading audio: $e');
      print('Stack trace: $st');
    } finally {
      loadingNotifier.value = false;
    }
  }

  void _setupListeners() {
    _playerStateSub = audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      playingNotifier.value = state.playing;
      
      // لاگ برای دیباگ
      print('Player state: playing=${state.playing}, processingState=${state.processingState}');
    });

    _durationSub = audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration = newDuration;
        durationNotifier.value = newDuration;
      }
    });

    _positionSub = audioPlayer.positionStream.listen((newPosition) {
      position = newPosition;
      positionNotifier.value = newPosition;
    });

    // گوش دادن به خطاها
    audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        print('❌ Audio playback error: $e');
        print('Stack trace: $st');
      },
    );
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        print('⏸️ Paused');
      } else {
        await audioPlayer.play();
        print('▶️ Playing');
      }
    } catch (e) {
      print('❌ Error toggling play/pause: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('❌ Error seeking: $e');
    }
  }

  Future<void> skipBackward() async {
    final newPosition = position - const Duration(seconds: 10);
    await seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  Future<void> skipForward() async {
    final newPosition = position + const Duration(seconds: 10);
    await seekTo(newPosition > duration ? duration : newPosition);
  }

  Future<void> purchaseBeat(BuildContext context) async {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      _showSnackBar(
        context,
        'لطفا ابتدا وارد شوید',
        AppTheme.errorColor,
      );
      return;
    }

    // بررسی خرید قبلی
    final isPurchased = await _db.isBeatPurchased(beat.id, currentUser.uid);
    if (isPurchased) {
      _showSnackBar(
        context,
        'شما قبلاً این بیت را خریداری کردهاید',
        AppTheme.warningColor,
      );
      return;
    }

    // محاسبه قیمت
    final price = _getPriceForLicense(selectedLicense);
    if (price == 0) {
      _showSnackBar(
        context,
        'این نوع لایسنس موجود نیست',
        AppTheme.errorColor,
      );
      return;
    }

    // نمایش دیالوگ تایید
    final confirmed = await _showConfirmationDialog(context, price);
    if (confirmed != true) return;

    loadingNotifier.value = true;

    try {
      final transaction = await _payment.processPayment(
        buyerId: currentUser.uid,
        beatId: beat.id,
        beatTitle: beat.title,
        producerId: beat.producerId,
        amount: price,
        licenseType: selectedLicense,
      );

      if (context.mounted) {
        _showSnackBar(
          context,
          'خرید با موفقیت انجام شد!',
          AppTheme.successColor,
        );
        _showSuccessDialog(context, transaction.transactionReference);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'خطا در پردازش: ${e.toString()}',
          AppTheme.errorColor,
        );
      }
    } finally {
      loadingNotifier.value = false;
    }
  }

  double _getPriceForLicense(LicenseType type) {
    switch (type) {
      case LicenseType.mp3:
        return beat.mp3Price ?? beat.price;
      case LicenseType.wav:
        return beat.wavPrice ?? beat.price;
      case LicenseType.stems:
        return beat.stemsPrice ?? 0;
      case LicenseType.exclusive:
        return beat.exclusivePrice ?? 0;
    }
  }

  String getLicenseTypeName(LicenseType type) {
    switch (type) {
      case LicenseType.mp3:
        return 'MP3';
      case LicenseType.wav:
        return 'WAV';
      case LicenseType.stems:
        return 'Stems';
      case LicenseType.exclusive:
        return 'انحصاری';
    }
  }

  String formatDuration(Duration duration) {
    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, double price) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تایید خرید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بیت: ${beat.title}'),
            Text('لایسنس: ${getLicenseTypeName(selectedLicense)}'),
            const SizedBox(height: 8),
            Text(
              'مبلغ: ${price.toStringAsFixed(0)} تومان',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('پرداخت'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String transactionRef) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خرید موفق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle,
              size: 60,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            Text('شماره تراکنش: $transactionRef'),
            const SizedBox(height: 8),
            const Text('فایل بیت اکنون در دسترس شماست'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void dispose() {
    _playerStateSub.cancel();
    _durationSub.cancel();
    _positionSub.cancel();
    audioPlayer.dispose();
    playingNotifier.dispose();
    positionNotifier.dispose();
    durationNotifier.dispose();
    loadingNotifier.dispose();
  }
}