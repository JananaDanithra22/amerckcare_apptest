// lib/core/services/session_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Session timeout configuration
class SessionConfig {
  /// Time of inactivity before showing warning dialog (5 minutes)
  static const Duration inactivityTimeout = Duration(minutes: 1);

  /// Time user has to respond to warning before auto-logout (1 minute)
  static const Duration warningTimeout = Duration(seconds: 30);

  /// Time in background before auto-logout (30 seconds)
  static const Duration backgroundTimeout = Duration(minutes: 1);
}

/// Smart session manager for healthcare app security
/// Handles inactivity and background timeouts with warnings
class SessionManager {
  // ✅ Singleton pattern
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Timers
  Timer? _inactivityTimer;
  Timer? _warningTimer;
  Timer? _backgroundTimer;

  // State tracking
  DateTime _lastActivityTime = DateTime.now();
  bool _isWarningShown = false;
  bool _isInBackground = false;
  bool _isEnabled = false;

  // Callbacks
  VoidCallback? _onWarningShow;
  VoidCallback? _onLogout;
  BuildContext? _context;

  /// Initialize session manager with callbacks
  void initialize({
    required BuildContext context,
    required VoidCallback onWarningShow,
    required VoidCallback onLogout,
  }) {
    _context = context;
    _onWarningShow = onWarningShow;
    _onLogout = onLogout;

    debugPrint('🔐 SessionManager initialized');
  }

  /// Start monitoring user session
  void startSession() {
    if (_isEnabled) return;

    _isEnabled = true;
    _lastActivityTime = DateTime.now();
    _isWarningShown = false;
    _isInBackground = false;

    _startInactivityTimer();

    debugPrint('✅ Session monitoring started');
    debugPrint(
      '   Inactivity timeout: ${SessionConfig.inactivityTimeout.inMinutes} minutes',
    );
    debugPrint(
      '   Background timeout: ${SessionConfig.backgroundTimeout.inSeconds} seconds',
    );
  }

  /// Stop monitoring (call on logout)
  void stopSession() {
    _isEnabled = false;
    _cancelAllTimers();

    debugPrint('🛑 Session monitoring stopped');
  }

  /// Record user activity (tap, scroll, navigation, etc.)
  void recordActivity() {
    if (!_isEnabled) return;

    _lastActivityTime = DateTime.now();

    // Reset warning if shown
    if (_isWarningShown) {
      _isWarningShown = false;
      _warningTimer?.cancel();
    }

    // Restart inactivity timer
    _restartInactivityTimer();
  }

  /// Called when app goes to background
  void onAppPaused() {
    if (!_isEnabled) return;

    _isInBackground = true;
    _inactivityTimer?.cancel();
    _startBackgroundTimer();

    debugPrint('⏸️  App backgrounded - starting 30s timer');
  }

  /// Called when app comes to foreground
  void onAppResumed() {
    if (!_isEnabled) return;

    _isInBackground = false;
    _backgroundTimer?.cancel();

    final timeInBackground = DateTime.now().difference(_lastActivityTime);

    if (timeInBackground > SessionConfig.backgroundTimeout) {
      debugPrint('❌ Background timeout exceeded');
      _performLogout();
    } else {
      debugPrint('✅ App resumed - restarting session monitoring');
      recordActivity(); // Reset activity time
    }
  }

  /// Start/restart inactivity timer
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(SessionConfig.inactivityTimeout, () {
      debugPrint('⚠️  Inactivity timeout reached - showing warning');
      _showWarningDialog();
    });
  }

  void _restartInactivityTimer() {
    _inactivityTimer?.cancel();
    _startInactivityTimer();
  }

  /// Start background timer
  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();

    _backgroundTimer = Timer(SessionConfig.backgroundTimeout, () {
      debugPrint('❌ Background timeout exceeded');
      _performLogout();
    });
  }

  /// Show warning dialog
  void _showWarningDialog() {
    if (_isWarningShown || !_isEnabled) return;

    _isWarningShown = true;

    // Notify parent to show warning
    _onWarningShow?.call();

    // Start warning timer (user has 1 minute to respond)
    _warningTimer = Timer(SessionConfig.warningTimeout, () {
      debugPrint('❌ Warning timeout - auto logout');
      _performLogout();
    });
  }

  /// Dismiss warning (user is still active)
  void dismissWarning() {
    _isWarningShown = false;
    _warningTimer?.cancel();
    recordActivity();

    debugPrint('✅ Warning dismissed - session extended');
  }

  /// Perform logout
  void _performLogout() {
    if (!_isEnabled) return;

    _cancelAllTimers();
    _isEnabled = false;

    debugPrint('🔴 Performing auto-logout due to timeout');

    _onLogout?.call();
  }

  /// Cancel all timers
  void _cancelAllTimers() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    _backgroundTimer?.cancel();
  }

  /// Get time until warning
  Duration getTimeUntilWarning() {
    if (!_isEnabled) return Duration.zero;

    final elapsed = DateTime.now().difference(_lastActivityTime);
    final remaining = SessionConfig.inactivityTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if session is active
  bool get isSessionActive => _isEnabled;

  /// Check if warning is shown
  bool get isWarningVisible => _isWarningShown;

  /// Dispose (cleanup)
  void dispose() {
    _cancelAllTimers();
    _context = null;
    _onWarningShow = null;
    _onLogout = null;
  }
}
