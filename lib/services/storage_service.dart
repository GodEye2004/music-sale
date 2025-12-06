import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Directory paths
  late Directory _beatsDirectory;
  late Directory _coversDirectory;
  late Directory _profilesDirectory;

  // Initialize storage directories
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();

    _beatsDirectory = Directory(path.join(appDir.path, 'beats'));
    _coversDirectory = Directory(path.join(appDir.path, 'covers'));
    _profilesDirectory = Directory(path.join(appDir.path, 'profiles'));

    // Create directories if they don't exist
    if (!await _beatsDirectory.exists()) {
      await _beatsDirectory.create(recursive: true);
    }
    if (!await _coversDirectory.exists()) {
      await _coversDirectory.create(recursive: true);
    }
    if (!await _profilesDirectory.exists()) {
      await _profilesDirectory.create(recursive: true);
    }
  }

  // ==================== BEAT AUDIO FILES ====================

  // Save beat audio file
  Future<String> saveBeatAudioFile(File sourceFile, String beatId) async {
    final fileName = '$beatId${path.extension(sourceFile.path)}';
    final destinationPath = path.join(_beatsDirectory.path, fileName);
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  // Get beat audio file
  File? getBeatAudioFile(String filePath) {
    final file = File(filePath);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  // Delete beat audio file
  Future<void> deleteBeatAudioFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==================== COVER IMAGES ====================

  // Save cover image
  Future<String> saveCoverImage(File sourceFile, String beatId) async {
    final fileName = '$beatId${path.extension(sourceFile.path)}';
    final destinationPath = path.join(_coversDirectory.path, fileName);
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  // Get cover image file
  File? getCoverImageFile(String? filePath) {
    if (filePath == null) return null;
    final file = File(filePath);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  // Delete cover image
  Future<void> deleteCoverImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==================== PROFILE IMAGES ====================

  // Save profile image
  Future<String> saveProfileImage(File sourceFile, String userId) async {
    final fileName = '$userId${path.extension(sourceFile.path)}';
    final destinationPath = path.join(_profilesDirectory.path, fileName);
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  // Get profile image file
  File? getProfileImageFile(String? filePath) {
    if (filePath == null) return null;
    final file = File(filePath);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  // Delete profile image
  Future<void> deleteProfileImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ==================== UTILITY ====================

  // Get file size in MB
  Future<double> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.length();
      return bytes / (1024 * 1024); // Convert to MB
    }
    return 0.0;
  }

  // Get storage usage
  Future<Map<String, double>> getStorageUsage() async {
    double beatsSize = 0;
    double coversSize = 0;
    double profilesSize = 0;

    // Calculate beats directory size
    await for (var entity in _beatsDirectory.list(recursive: true)) {
      if (entity is File) {
        beatsSize += await entity.length();
      }
    }

    // Calculate covers directory size
    await for (var entity in _coversDirectory.list(recursive: true)) {
      if (entity is File) {
        coversSize += await entity.length();
      }
    }

    // Calculate profiles directory size
    await for (var entity in _profilesDirectory.list(recursive: true)) {
      if (entity is File) {
        profilesSize += await entity.length();
      }
    }

    return {
      'beats': beatsSize / (1024 * 1024), // MB
      'covers': coversSize / (1024 * 1024),
      'profiles': profilesSize / (1024 * 1024),
      'total': (beatsSize + coversSize + profilesSize) / (1024 * 1024),
    };
  }

  // Clear all storage (for testing)
  Future<void> clearAllStorage() async {
    // Delete all files in beats directory
    await for (var entity in _beatsDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }

    // Delete all files in covers directory
    await for (var entity in _coversDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }

    // Delete all files in profiles directory
    await for (var entity in _profilesDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }
}
