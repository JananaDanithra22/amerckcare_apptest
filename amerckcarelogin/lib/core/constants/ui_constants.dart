// lib/core/constants/ui_constants.dart
import 'package:flutter/material.dart';

/// UI-related constants for consistent styling
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Button Dimensions
  static const double buttonHeight = 56.0;
  static const double buttonWidth = 250.0;
  static const double buttonRadius = 12.0;
  static const double buttonPaddingH = 24.0;
  static const double buttonPaddingV = 14.0;

  // Input Field Dimensions
  static const double fieldRadius = 12.0;
  static const double fieldPaddingH = 16.0;
  static const double fieldPaddingV = 16.0;
  static const double fieldMinHeight = 56.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusCircle = 999.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXl = 100.0;

  // Card Properties
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );

  // Colors
  static const Color primaryBlue = Color(0xFF1C8AE5);
  static const Color darkBlue = Color(0xFF0650A2);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFEEEEEE);
  static const Color fieldBackground = Color(0xFFEEEEEE);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);

  // Shadows
  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowHeavy => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // Animations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, darkBlue],
  );

  // Border Styles
  static BorderSide get borderNormal =>
      BorderSide(color: Colors.grey.shade300, width: 1.0);

  static BorderSide get borderError =>
      const BorderSide(color: errorRed, width: 1.5);

  static BorderSide get borderFocused =>
      const BorderSide(color: primaryBlue, width: 2.0);
}
