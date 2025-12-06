import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';

class UploadBeatScreen extends StatefulWidget {
  const UploadBeatScreen({super.key});

  @override
  State<UploadBeatScreen> createState() => _UploadBeatScreenState();
}

class _UploadBeatScreenState extends State<UploadBeatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bpmController = TextEditingController();
  final _mp3PriceController = TextEditingController();
  final _wavPriceController = TextEditingController();
  final _stemsPriceController = TextEditingController();

  final DatabaseService _db = DatabaseService();
  final StorageService _storage = StorageService();
  final AuthService _auth = AuthService();
  final Uuid _uuid = const Uuid();

  String? _selectedGenre;
  String? _selectedKey;
  File? _audioFile;
  File? _coverImage;
  bool _isUploading = false;
  List<String> _selectedTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bpmController.dispose();
    _mp3PriceController.dispose();
    _wavPriceController.dispose();
    _stemsPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeInMB = await _storage.getFileSize(file.path);

        if (sizeInMB > AppConstants.maxAudioFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حجم فایل نباید بیشتر از ${AppConstants.maxAudioFileSize} مگابایت باشد',
                ),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          return;
        }

        setState(() {
          _audioFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در انتخاب فایل: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      print('Error picking audio file: $e');
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final sizeInMB = await _storage.getFileSize(file.path);

        if (sizeInMB > AppConstants.maxImageFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'حجم تصویر نباید بیشتر از ${AppConstants.maxImageFileSize} مگابایت باشد',
                ),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          return;
        }

        setState(() {
          _coverImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در انتخاب تصویر: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      print('Error picking cover image: $e');
    }
  }

  Future<void> _uploadBeat() async {
    if (!_formKey.currentState!.validate()) return;

    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا فایل صوتی را انتخاب کنید'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا ژانر را انتخاب کنید'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا کلید موسیقی را انتخاب کنید'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final currentUser = _auth.currentUser!;
      final beatId = _uuid.v4();

      // Save audio file
      final audioPath = await _storage.saveBeatAudioFile(_audioFile!, beatId);

      // Save cover image if selected
      String? coverPath;
      if (_coverImage != null) {
        coverPath = await _storage.saveCoverImage(_coverImage!, beatId);
      }

      // Get default price (MP3)
      final defaultPrice = double.tryParse(_mp3PriceController.text) ?? 0;

      // Create beat
      final beat = Beat(
        id: beatId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        producerId: currentUser.uid,
        producerName: currentUser.displayName,
        genre: _selectedGenre!,
        bpm: int.parse(_bpmController.text),
        musicalKey: _selectedKey!,
        price: defaultPrice,
        previewPath: audioPath, // For now, use same file for preview
        fullPath: audioPath,
        coverImagePath: coverPath,
        uploadDate: DateTime.now(),
        tags: _selectedTags,
        mp3Price: double.tryParse(_mp3PriceController.text),
        wavPrice: double.tryParse(_wavPriceController.text),
        stemsPrice: double.tryParse(_stemsPriceController.text),
      );

      await _db.addBeat(beat);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('بیت با موفقیت آپلود شد!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در آپلود: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('آپلود بیت جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Audio File Picker
              Card(
                child: InkWell(
                  onTap: _pickAudioFile,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          _audioFile != null
                              ? Icons.audio_file
                              : Icons.upload_file,
                          size: 50,
                          color: _audioFile != null
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _audioFile != null
                              ? _audioFile!.path.split('/').last
                              : 'انتخاب فایل صوتی',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (_audioFile == null)
                          Text(
                            'حداکثر ${AppConstants.maxAudioFileSize} مگابایت',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cover Image Picker
              Card(
                child: InkWell(
                  onTap: _pickCoverImage,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _coverImage != null
                        ? Column(
                            children: [
                              Image.file(
                                _coverImage!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 8),
                              const Text('تصویر کاور'),
                            ],
                          )
                        : Column(
                            children: [
                              const Icon(
                                Icons.image,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 8),
                              const Text('انتخاب تصویر کاور (اختیاری)'),
                              Text(
                                'حداکثر ${AppConstants.maxImageFileSize} مگابایت',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان بیت',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا عنوان را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: AppConstants.maxDescriptionLength,
                decoration: const InputDecoration(
                  labelText: 'توضیحات',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا توضیحات را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Genre
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: const InputDecoration(
                  labelText: 'ژانر',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.genres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGenre = value);
                },
              ),

              const SizedBox(height: 16),

              // BPM and Key
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bpmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'BPM',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الزامی';
                        }
                        final bpm = int.tryParse(value);
                        if (bpm == null ||
                            bpm < AppConstants.minBpm ||
                            bpm > AppConstants.maxBpm) {
                          return 'نامعتبر';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedKey,
                      decoration: const InputDecoration(
                        labelText: 'کلید',
                        prefixIcon: Icon(Icons.music_note),
                      ),
                      items: AppConstants.musicalKeys.map((key) {
                        return DropdownMenuItem(value: key, child: Text(key));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedKey = value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pricing
              Text(
                'قیمت‌گذاری (تومان)',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _mp3PriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'قیمت MP3',
                  prefixIcon: Icon(Icons.monetization_on),
                  hintText: '0',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'قیمت نامعتبر';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _wavPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'قیمت WAV (اختیاری)',
                  prefixIcon: Icon(Icons.monetization_on),
                  hintText: '0',
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _stemsPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'قیمت Stems (اختیاری)',
                  prefixIcon: Icon(Icons.monetization_on),
                  hintText: '0',
                ),
              ),

              const SizedBox(height: 32),

              // Upload Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadBeat,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'در حال آپلود...' : 'آپلود بیت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
