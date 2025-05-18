import 'package:flutter/material.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/screens/splash/viewmodel/splash_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final splashViewModel = Provider.of<SplashViewModel>(context, listen: false);

    Future.microtask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        splashViewModel.checkLogin(context);
        splashViewModel.checkFirstTime(context);

        // splashViewModel.testNavigateToQrScreen(context);
      });
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bg_spash),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Image.asset(AppImages.logo_greenhouse),
          ),
        ),
      ),
    );
  }
}
