import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomSuccessScreen extends StatelessWidget {
  final String title;
  final String message;
  final String animationAsset;
  final bool showButton;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Duration? autoRedirectDelay;
  final VoidCallback? onAutoRedirect;

  const CustomSuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.animationAsset,
    this.showButton = false,
    this.buttonText,
    this.onButtonPressed,
    this.autoRedirectDelay,
    this.onAutoRedirect,
  });

  @override
  Widget build(BuildContext context) {
    if (autoRedirectDelay != null && onAutoRedirect != null) {
      Future.delayed(autoRedirectDelay!, onAutoRedirect!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                animationAsset,
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3F2F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              if (showButton && buttonText != null && onButtonPressed != null)
                ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(buttonText!),
                )
            ],
          ),
        ),
      ),
    );
  }
}
