import 'dart:ui';

class SuccessScreenArgs {
  final String title;
  final String message;
  final String animationAsset;
  final bool showButton;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Duration autoRedirectDelay;
  final VoidCallback onAutoRedirect;

  SuccessScreenArgs({
    required this.title,
    required this.message,
    required this.animationAsset,
    required this.showButton,
    required this.buttonText,
    required this.onButtonPressed,
    required this.autoRedirectDelay,
    required this.onAutoRedirect,
  });
}
