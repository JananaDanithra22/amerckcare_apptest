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
  Future<bool> pickAndSetPhoto(BuildContext context) async {
    File? picked;

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
                  // Handle bar
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
                    onTap: () async {
                      Navigator.pop(ctx);
                      final result = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      if (result != null) picked = File(result.path);
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
                    onTap: () async {
                      Navigator.pop(ctx);
                      final result = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      if (result != null) picked = File(result.path);
                    },
                  ),

                  // Remove (only show if photo exists)
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
                        Navigator.pop(ctx);
                        clearPhoto();
                      },
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );

    if (picked != null) {
      _photoFile = picked;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Clear photo (on remove or logout)
  void clearPhoto() {
    _photoFile = null;
    notifyListeners();
  }
}
