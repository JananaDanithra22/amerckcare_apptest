import 'package:flutter/material.dart';

/// Global overlay controller - Use this anywhere in your app
class GlobalOverlayController extends ChangeNotifier {
  static final GlobalOverlayController _instance =
      GlobalOverlayController._internal();
  factory GlobalOverlayController() => _instance;
  GlobalOverlayController._internal();

  bool _isLoading = false;
  String? _message;
  String? _subtitle;
  double? _progress;
  Widget? _customContent;

  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get subtitle => _subtitle;
  double? get progress => _progress;
  Widget? get customContent => _customContent;

  /// Show simple loading overlay with message
  void show([String? message]) {
    _isLoading = true;
    _message = message;
    _subtitle = null;
    _progress = null;
    _customContent = null;
    notifyListeners();
  }

  /// Show overlay with progress (0.0 to 1.0)
  void showProgress(double progress, [String? message, String? subtitle]) {
    _isLoading = true;
    _progress = progress;
    _message = message;
    _subtitle = subtitle;
    _customContent = null;
    notifyListeners();
  }

  /// Show overlay with custom widget
  void showCustom(Widget customContent) {
    _isLoading = true;
    _customContent = customContent;
    _message = null;
    _subtitle = null;
    _progress = null;
    notifyListeners();
  }

  /// Update message without hiding
  void updateMessage(String message, [String? subtitle]) {
    if (_isLoading) {
      _message = message;
      _subtitle = subtitle;
      notifyListeners();
    }
  }

  /// Update progress
  void updateProgress(double progress, [String? message]) {
    if (_isLoading) {
      _progress = progress;
      if (message != null) _message = message;
      notifyListeners();
    }
  }

  /// Hide overlay
  void hide() {
    _isLoading = false;
    _message = null;
    _subtitle = null;
    _progress = null;
    _customContent = null;
    notifyListeners();
  }

  /// Show overlay for specific duration
  Future<void> showTemporary(Duration duration, [String? message]) async {
    show(message);
    await Future.delayed(duration);
    hide();
  }

  /// Execute async function with overlay
  Future<T> withOverlay<T>(
    Future<T> Function() function, {
    String? message,
    String? successMessage,
    Duration? successDuration,
  }) async {
    try {
      show(message ?? 'Please wait...');
      final result = await function();

      if (successMessage != null) {
        updateMessage(successMessage);
        await Future.delayed(successDuration ?? const Duration(seconds: 1));
      }

      hide();
      return result;
    } catch (e) {
      hide();
      rethrow;
    }
  }
}

/// The overlay widget that wraps your entire app
class GlobalLoadingOverlay extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? logoAssetPath;

  const GlobalLoadingOverlay({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.progressColor,
    this.logoAssetPath = 'assets/images/signlogo.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GlobalOverlayController(),
      builder: (context, _) {
        final controller = GlobalOverlayController();

        return Stack(
          children: [
            child,
            if (controller.isLoading)
              AnimatedOpacity(
                opacity: controller.isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Material(
                  color: (backgroundColor ?? Colors.white).withOpacity(0.85),
                  child: Center(
                    child:
                        controller.customContent ??
                        _buildDefaultOverlay(controller),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultOverlay(GlobalOverlayController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        if (logoAssetPath != null)
          Image.asset(
            logoAssetPath!,
            height: 60,
            width: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        if (logoAssetPath != null) const SizedBox(height: 24),

        // Progress indicator
        if (controller.progress != null) ...[
          SizedBox(
            width: 200,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontFamily: 'Roboto',
                    decoration: TextDecoration.none,
                  ),
                  child: Text('${(controller.progress! * 100).toInt()}%'),
                ),
              ],
            ),
          ),
        ] else
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? const Color(0xFF2196F3),
            ),
          ),

        // Message
        if (controller.message != null) ...[
          const SizedBox(height: 16),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Roboto',
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            child: Text(controller.message!),
          ),
        ],

        // Subtitle
        if (controller.subtitle != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontFamily: 'Roboto',
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            child: Text(controller.subtitle!),
          ),
        ],
      ],
    );
  }
}

/// Extension for easy access in any widget
extension BuildContextOverlay on BuildContext {
  GlobalOverlayController get overlay => GlobalOverlayController();
}
