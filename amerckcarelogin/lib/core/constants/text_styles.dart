// lib/core/constants/text_styles.dart

import 'package:flutter/material.dart';
import 'ui_constants.dart';

/// Centralized text styles for the ENTIRE application
/// Use these instead of creating TextStyle() objects anywhere
/// 
/// Benefits:
/// - Consistency across all screens
/// - Easy to update (change once, affects entire app)
/// - Less code duplication
/// - Better maintainability
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ============================================================
  // HEADINGS - Use for page titles, section headers
  // ============================================================

  /// Extra Large heading - App bar titles, main page headers
  /// Example: "Settings", "Profile", "About Us"
  static const TextStyle headingXLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
    letterSpacing: 0.5,
  );

  /// Large heading - Page titles, dialog titles
  /// Example: "My Profile", "Change Password"
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
    letterSpacing: 0.5,
  );

  /// Medium heading - Section titles, card headers
  /// Example: "Account Settings", "Security & Privacy"
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Small heading - Sub-section titles
  /// Example: "Professional Information", "Contact Information"
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  // ============================================================
  // BODY TEXT - Use for main content, descriptions
  // ============================================================

  /// Body text - Extra Large (emphasis)
  static const TextStyle bodyXLarge = TextStyle(
    fontSize: 18,
    color: UIConstants.textDark,
    height: 1.5,
  );

  /// Body text - Large (main content)
  /// Example: Main descriptions, important text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: UIConstants.textDark,
    height: 1.5,
  );

  /// Body text - Medium (most common)
  /// Example: Regular text, paragraphs, descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: UIConstants.textDark,
    height: 1.4,
  );

  /// Body text - Small (helper text)
  /// Example: Hints, small descriptions, metadata
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
    height: 1.4,
  );

  // ============================================================
  // SETTINGS / LIST TILES - Use for all list items
  // ============================================================

  /// List tile title - Used for ALL list item titles
  /// Example: "Biometric Login", "Change Password", "Edit Profile"
  static const TextStyle listTileTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: UIConstants.textDark,
  );

  /// List tile subtitle - Used for ALL list item subtitles
  /// Example: "Set up and manage biometric login"
  static const TextStyle listTileSubtitle = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  // Aliases for backward compatibility and clarity
  static const TextStyle settingsTileTitle = listTileTitle;
  static const TextStyle settingsTileSubtitle = listTileSubtitle;

  // ============================================================
  // LABELS - Use for form labels, field labels
  // ============================================================

  /// Label text - Bold/Required
  /// Example: "Email *", "Password *"
  static const TextStyle labelBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Label text - Regular
  /// Example: "Enter your email", form field labels
  static const TextStyle labelRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.textDark,
  );

  /// Label text - Small
  /// Example: "Optional", tiny labels, metadata
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  /// Label text - Tiny
  /// Example: Version numbers, timestamps
  static const TextStyle labelTiny = TextStyle(
    fontSize: 10,
    color: UIConstants.textLight,
  );

  // ============================================================
  // BUTTONS - Use for all button text
  // ============================================================

  /// Button text - Large (primary actions)
  /// Example: "Sign In", "Continue", "Submit"
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  /// Button text - Medium (secondary actions)
  /// Example: "Cancel", "Skip", smaller buttons
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Button text - Small (tertiary actions)
  /// Example: Small action buttons, chips
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ============================================================
  // SPECIAL STATES - Use for errors, success, warnings
  // ============================================================

  /// Error text - For error messages
  /// Example: "Invalid email", "Password too short"
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.errorRed,
  );

  /// Success text - For success messages
  /// Example: "Password changed successfully"
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.successGreen,
  );

  /// Warning text - For warning messages
  /// Example: "Session will expire soon"
  static const TextStyle warning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.warningOrange,
  );

  /// Link text - For clickable links
  /// Example: "Forgot Password?", "Learn more"
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: UIConstants.primaryBlue,
    decoration: TextDecoration.underline,
  );

  /// Link text - Small
  /// Example: Small footer links
  static const TextStyle linkSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: UIConstants.primaryBlue,
    decoration: TextDecoration.underline,
  );

  /// Caption text - Very small text
  /// Example: Copyright, fine print
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: UIConstants.textLight,
    height: 1.3,
  );

  // ============================================================
  // STAT CARDS - Use for dashboard statistics
  // ============================================================

  /// Stat value (large number) - For dashboard numbers
  /// Example: "12", "4.8", "1,234"
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Stat value - Large (emphasized numbers)
  static const TextStyle statValueLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Stat label - For stat descriptions
  /// Example: "Today", "Rating", "Total"
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  // ============================================================
  // SECTION HEADERS - Use for section dividers
  // ============================================================

  /// Section header with icon - For card/section titles
  /// Example: "Professional Information", "Account Settings"
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Section header - Small
  static const TextStyle sectionHeaderSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  // ============================================================
  // INFO ROWS - Use for profile info displays
  // ============================================================

  /// Info row label - For field names
  /// Example: "Email:", "Phone:", "License:"
  static const TextStyle infoRowLabel = TextStyle(
    fontSize: 12,
    color: UIConstants.textMedium,
  );

  /// Info row value - For field values
  /// Example: "john@example.com", "+1 555-1234"
  static const TextStyle infoRowValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: UIConstants.textDark,
  );

  // ============================================================
  // CARDS - Use for card content
  // ============================================================

  /// Card title - For card headers
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Card subtitle - For card descriptions
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: UIConstants.textMedium,
  );

  /// Card body - For card content
  static const TextStyle cardBody = TextStyle(
    fontSize: 14,
    color: UIConstants.textDark,
    height: 1.4,
  );

  // ============================================================
  // BADGES & CHIPS - Use for small tags
  // ============================================================

  /// Badge text - For status badges
  /// Example: "Active", "Online", "Verified"
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Chip text - For filter chips, action chips
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: UIConstants.textDark,
  );

  // ============================================================
  // INPUT FIELDS - Use for text field text
  // ============================================================

  /// Input text - Text inside input fields
  static const TextStyle input = TextStyle(
    fontSize: 16,
    color: UIConstants.textDark,
  );

  /// Input hint - Placeholder text
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    color: UIConstants.textLight,
  );

  /// Input error - Error text below input
  static const TextStyle inputError = TextStyle(
    fontSize: 13,
    color: UIConstants.errorRed,
    fontWeight: FontWeight.w500,
  );

  // ============================================================
  // APP BAR - Use for app bar text
  // ============================================================

  /// App bar title - For AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ============================================================
  // DIALOG - Use for dialog content
  // ============================================================

  /// Dialog title - For dialog headers
  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: UIConstants.textDark,
  );

  /// Dialog content - For dialog body
  static const TextStyle dialogContent = TextStyle(
    fontSize: 14,
    color: UIConstants.textMedium,
    height: 1.5,
  );

  // ============================================================
  // SNACKBAR - Use for snackbar messages
  // ============================================================

  /// Snackbar text
  static const TextStyle snackbar = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );
}