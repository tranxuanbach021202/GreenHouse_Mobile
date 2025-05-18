import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlayWidget({super.key, required this.isLoading, required this.child});


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: 120,
                height: 120,
              ),
            ),
          ),
      ],
    );
  }
}
