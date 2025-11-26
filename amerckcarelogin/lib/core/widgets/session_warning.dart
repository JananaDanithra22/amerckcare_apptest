// lib/core/widgets/session_warning_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/session_manager.dart';

/// Simple session warning dialog:
/// - 60s countdown
/// - "Stay signed in" and "Logout" actions
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
      // prevent dismiss by system back
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text('Are you still there?'),
        content: Text(
          'You have been inactive. You’ll be logged out automatically in $_countdownText.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _timer.cancel();
              widget.onLogout();
            },
            child: const Text('Logout'),
          ),
          TextButton(
            onPressed: () {
              // keep behavior from original: dismiss warning and continue
              SessionManager().dismissWarning();
              _timer.cancel();
              Navigator.of(context).pop();
              widget.onContinue();
            },
            child: const Text('Stay signed in'),
          ),
        ],
      ),
    );
  }
}
