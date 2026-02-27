// lib/features/profile/providers/profile_avatar_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatarProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  File? _photoFile; // held in memory only
  bool _isLoading = false;

  File? get photoFile => _photoFile;
  bool get isLoading => _isLoading;
  bool get hasPhoto => _photoFile != null;

  /// Show bottom sheet and pick image from camera or gallery
  /// Show bottom sheet and pick image from camera or gallery
  Future<bool> pickAndSetPhoto(BuildContext context) async {
    ImageSource? selectedSource;
    bool shouldRemove = false;

    // Step 1: Show bottom sheet and WAIT for user selection
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Update Profile Photo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Camera
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                    title: const Text('Take a Photo'),
                    subtitle: const Text('Use your camera'),
                    onTap: () {
                      selectedSource = ImageSource.camera; // ← just set source
                      Navigator.pop(ctx); // ← close sheet
                    },
                  ),

                  // Gallery
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.purple,
                      ),
                    ),
                    title: const Text('Choose from Gallery'),
                    subtitle: const Text('Pick an existing photo'),
                    onTap: () {
                      selectedSource = ImageSource.gallery; // ← just set source
                      Navigator.pop(ctx); // ← close sheet
                    },
                  ),

                  // Remove (only if photo exists)
                  if (_photoFile != null)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                      title: const Text('Remove Photo'),
                      subtitle: const Text('Go back to default avatar'),
                      onTap: () {
                        shouldRemove = true; // ← flag to remove
                        Navigator.pop(ctx);
                      },
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );

    // Step 2: Handle remove
    if (shouldRemove) {
      clearPhoto();
      return false; // not a new photo — caller handles snackbar separately
    }

    // Step 3: No selection made
    if (selectedSource == null) return false;

    // Step 4: NOW open camera/gallery AFTER bottom sheet is fully closed
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _picker.pickImage(
        source: selectedSource!,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (result != null) {
        _photoFile = File(result.path);
        _isLoading = false;
        notifyListeners(); // ← triggers UI rebuild everywhere
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear photo (on remove or logout)
  void clearPhoto() {
    _photoFile = null;
    notifyListeners();
  }
}
