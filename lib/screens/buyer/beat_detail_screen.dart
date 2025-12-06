import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/payment_service.dart';

class BeatDetailScreen extends StatefulWidget {
  final Beat beat;

  const BeatDetailScreen({super.key, required this.beat});

  @override
  State<BeatDetailScreen> createState() => _BeatDetailScreenState();
}

class _BeatDetailScreenState extends State<BeatDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final PaymentService _payment = PaymentService();

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  LicenseType _selectedLicense = LicenseType.mp3;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Load audio file
      await _audioPlayer.setFilePath(widget.beat.previewPath);

      // Listen to player state
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      // Listen to duration
      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });

      // Listen to position
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _purchaseBeat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا ابتدا وارد شوید'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Check if already purchased
    if (_db.isBeatPurchased(widget.beat.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('شما قبلاً این بیت را خریداری کرده‌اید'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    // Get price based on license type
    double price = 0;
    switch (_selectedLicense) {
      case LicenseType.mp3:
        price = widget.beat.mp3Price ?? widget.beat.price;
        break;
      case LicenseType.wav:
        price = widget.beat.wavPrice ?? widget.beat.price;
        break;
      case LicenseType.stems:
        price = widget.beat.stemsPrice ?? 0;
        break;
      case LicenseType.exclusive:
        price = widget.beat.exclusivePrice ?? 0;
        break;
    }

    if (price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('این نوع لایسنس موجود نیست'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تایید خرید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بیت: ${widget.beat.title}'),
            Text('لایسنس: ${_getLicenseTypeName(_selectedLicense)}'),
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

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Process payment (mock)
      final transaction = await _payment.processPayment(
        buyerId: currentUser.uid,
        beatId: widget.beat.id,
        beatTitle: widget.beat.title,
        producerId: widget.beat.producerId,
        amount: price,
        licenseType: _selectedLicense,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خرید با موفقیت انجام شد!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Show transaction details
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
                Text('شماره تراکنش: ${transaction.transactionReference}'),
                const SizedBox(height: 8),
                const Text('فایل بیت اکنون در دسترس شماست'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close detail screen
                },
                child: const Text('بستن'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در پردازش: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLicenseTypeName(LicenseType type) {
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPurchased = _db.isBeatPurchased(widget.beat.id);
    final currentUser = _auth.currentUser;
    final isOwnBeat =
        currentUser != null && currentUser.uid == widget.beat.producerId;

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
                  // Cover Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: widget.beat.coverImagePath != null
                          ? Image.file(
                              File(widget.beat.coverImagePath!),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.music_note,
                                size: 100,
                                color: Colors.white70,
                              ),
                            ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.beat.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),

                        const SizedBox(height: 8),

                        // Producer
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 20,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.beat.producerName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.speed,
                                label: 'BPM',
                                value: '${widget.beat.bpm}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.music_note,
                                label: 'Key',
                                value: widget.beat.musicalKey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.category,
                                label: 'Genre',
                                value: widget.beat.genre,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'توضیحات:',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.beat.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 24),

                        // Pricing Options or Status
                        if (isOwnBeat) ...[
                          // Producer's own beat
                          Card(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'بیت شما',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'این بیت متعلق به شماست',
                                          style: TextStyle(
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
                          ),
                        ] else if (!isPurchased) ...[
                          Text(
                            'انتخاب لایسنس:',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),

                          if (widget.beat.mp3Price != null)
                            _LicenseOption(
                              type: LicenseType.mp3,
                              name: 'MP3',
                              price: widget.beat.mp3Price!,
                              isSelected: _selectedLicense == LicenseType.mp3,
                              onTap: () => setState(
                                () => _selectedLicense = LicenseType.mp3,
                              ),
                            ),

                          if (widget.beat.wavPrice != null)
                            _LicenseOption(
                              type: LicenseType.wav,
                              name: 'WAV',
                              price: widget.beat.wavPrice!,
                              isSelected: _selectedLicense == LicenseType.wav,
                              onTap: () => setState(
                                () => _selectedLicense = LicenseType.wav,
                              ),
                            ),

                          if (widget.beat.stemsPrice != null)
                            _LicenseOption(
                              type: LicenseType.stems,
                              name: 'Stems',
                              price: widget.beat.stemsPrice!,
                              isSelected: _selectedLicense == LicenseType.stems,
                              onTap: () => setState(
                                () => _selectedLicense = LicenseType.stems,
                              ),
                            ),
                        ] else ...[
                          Card(
                            color: AppTheme.successColor.withOpacity(0.2),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successColor,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'شما این بیت را خریداری کرده‌اید',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Audio Player
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                // Progress Bar
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),

                // Time and Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Play/Pause Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final newPosition =
                            _position - const Duration(seconds: 10);
                        _audioPlayer.seek(
                          newPosition < Duration.zero
                              ? Duration.zero
                              : newPosition,
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.elevatedShadow,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                        onPressed: _togglePlayPause,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        final newPosition =
                            _position + const Duration(seconds: 10);
                        _audioPlayer.seek(
                          newPosition > _duration ? _duration : newPosition,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Purchase Button (only for non-producers)
                if (!isPurchased && !isOwnBeat)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _purchaseBeat,
                        icon: _isLoading
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
                          _isLoading ? 'در حال پردازش...' : 'خرید بیت',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseOption extends StatelessWidget {
  final LicenseType type;
  final String name;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _LicenseOption({
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
