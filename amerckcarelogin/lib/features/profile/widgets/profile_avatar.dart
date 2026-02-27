// lib/features/profile/widgets/profile_avatar.dart

import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final File? photoFile;
  final String displayLetter;
  final double size;
  final Color letterColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ProfileAvatar({
    Key? key,
    required this.photoFile,
    required this.displayLetter,
    this.size = 100,
    this.letterColor = const Color(0xFF1C8AE5),
    this.backgroundColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child:
              photoFile != null
                  // Show real photo
                  ? Image.file(
                    photoFile!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => _letterFallback(),
                  )
                  // Show letter fallback
                  : _letterFallback(),
        ),
      ),
    );
  }

  Widget _letterFallback() {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          displayLetter,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: letterColor,
          ),
        ),
      ),
    );
  }
}
