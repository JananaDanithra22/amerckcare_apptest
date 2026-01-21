// lib/core/constants/text_styles.dart

import 'package:flutter/material.dart';
import 'ui_constants.dart';

/// Centralized text styles for consistent typography across the app
/// Use these instead of creating TextStyle() objects everywhere
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ============================================================
  // HEADINGS
  // ============================================================

  /// Large heading - Used for main page titles
  /// Example: "Settings", "Profile", "About Us"
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
    letterSpacing: 0.5,
  );

  /// Medium heading - Used for section titles
  /// Example: "Account Settings", "Security & Privacy"
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Small heading - Used for card titles
  /// Example: "Professional Information", "Contact Information"
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  // ============================================================
  // BODY TEXT
  // ============================================================

  /// Body text - Large
  /// Example: Main content, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: UIConstants.textDark,
    height: 1.5,
  );

  /// Body text - Medium (most common)
  /// Example: Regular text, list items
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: UIConstants.textDark,
    height: 1.4,
  );

  /// Body text - Small
  /// Example: Helper text, descriptions
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
    height: 1.4,
  );

  // ============================================================
  // SETTINGS / LIST TILES
  // ============================================================

  /// Settings tile title
  /// Example: "Biometric Login", "Change Password"
  static const TextStyle settingsTileTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: UIConstants.textDark,
  );

  /// Settings tile subtitle
  /// Example: "Set up and manage biometric login"
  static const TextStyle settingsTileSubtitle = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  // ============================================================
  // LABELS
  // ============================================================

  /// Label text - Bold
  /// Example: "Email", "Password", "Phone"
  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Label text - Regular
  /// Example: Form field labels
  static const TextStyle labelRegular = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  /// Label text - Small
  /// Example: Tiny labels, metadata
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    color: UIConstants.textMedium,
  );

  // ============================================================
  // BUTTONS
  // ============================================================

  /// Button text - Large
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Button text - Medium
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Button text - Small
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  /// Error text
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.errorRed,
  );

  /// Success text
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.successGreen,
  );

  /// Link text
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: UIConstants.primaryBlue,
    decoration: TextDecoration.underline,
  );

  /// Caption text
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: UIConstants.textLight,
  );

  // ============================================================
  // STAT CARDS
  // ============================================================

  /// Stat value (large number)
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Stat label
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  // ============================================================
  // SECTION HEADERS
  // ============================================================

  /// Section header with icon
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Info row label
  static const TextStyle infoRowLabel = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  /// Info row value
  static const TextStyle infoRowValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.textDark,
  );
}
