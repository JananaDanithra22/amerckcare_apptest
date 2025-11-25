// lib/core/services/session_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager {
  Timer? _inactivityTimer;
  DateTime? _backgroundTime;

  final Duration inactivityTimeout = Duration(minutes: 5);
  final Duration backgroundTimeout = Duration(seconds: 30);

  Function()? onSessionExpired;

  // Call when user interacts with app
  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      debugPrint('⏱️ Session expired due to inactivity');
      onSessionExpired?.call();
    });
  }

  // Call when app goes to background
  void onAppPaused() {
    _backgroundTime = DateTime.now();
    debugPrint('⏸️ App paused at: $_backgroundTime');
  }

  // Call when app comes to foreground
  void onAppResumed() {
    if (_backgroundTime != null) {
      final duration = DateTime.now().difference(_backgroundTime!);
      debugPrint('▶️ App resumed after: ${duration.inSeconds} seconds');

      if (duration > backgroundTimeout) {
        debugPrint('⏱️ Session expired due to background timeout');
        onSessionExpired?.call();
      } else {
        // Reset inactivity timer when app resumes
        resetInactivityTimer();
      }
    }
    _backgroundTime = null;
  }

  void dispose() {
    _inactivityTimer?.cancel();
    _backgroundTime = null;
  }
}
