import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/colors.dart';

import '../core/router/app_router.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      context.go('/signin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/success.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.stateGreen,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Bạn sẽ được chuyển hướng trong giây lát...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.stateGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
