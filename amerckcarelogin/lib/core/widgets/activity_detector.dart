// lib/core/widgets/activity_detector.dart - FIXED

import 'package:flutter/material.dart';
import '../utils/session_manager.dart';

/// Widget that detects user activity and updates SessionManager
/// Wrap your entire app with this to track all interactions
class ActivityDetector extends StatelessWidget {
  final Widget child;

  const ActivityDetector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ SIMPLIFIED: Listener alone is enough!
    // It detects ALL pointer events: taps, drags, scrolls, pinches
    return Listener(
      onPointerDown: (_) {
        // Triggered when user touches screen
        SessionManager().recordActivity();
      },
      onPointerMove: (_) {
        // Triggered when user drags/scrolls
        SessionManager().recordActivity();
      },
      onPointerUp: (_) {
        // Triggered when user releases touch
        SessionManager().recordActivity();
      },
      // Allow events to pass through to child widgets
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
