// lib/core/widgets/session_warning_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/session_manager.dart';

/// Session warning dialog with Lottie animation
/// - 60s countdown
/// - "Stay" and "Log Out" actions with hover effects
class SessionWarningDialog extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onLogout;

  const SessionWarningDialog({
    Key? key,
    required this.onContinue,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<SessionWarningDialog> createState() => _SessionWarningDialogState();
}

class _SessionWarningDialogState extends State<SessionWarningDialog> {
  late Timer _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        _timer.cancel();
        widget.onLogout();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _countdownText => '$_secondsRemaining s';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation at top center
              Lottie.asset(
                'assets/waiting.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.timer_outlined,
                    size: 80,
                    color: Colors.orange,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Are you still there?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message with countdown
              Text(
                'You have been inactive. You will be logged out automatically in $_countdownText.',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  // Log Out Button
                  Expanded(
                    child: _HoverButton(
                      label: 'Log Out',
                      onPressed: () {
                        _timer.cancel();
                        widget.onLogout();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stay Button
                  Expanded(
                    child: _HoverButton(
                      label: 'Stay',
                      onPressed: () {
                        SessionManager().dismissWarning();
                        _timer.cancel();
                        Navigator.of(context).pop();
                        widget.onContinue();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom button with hover effect
class _HoverButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _HoverButton({required this.label, required this.onPressed});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue : Colors.transparent,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isHovered ? Colors.white : Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
