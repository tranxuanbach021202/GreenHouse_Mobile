import 'package:flutter/material.dart';
import 'package:greenhouse/base/views/widget/custom_button_widget.dart';
import '../../core/colors.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            color: AppColors.culTured
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004A1E),
              ),
            ),
            CustomButtonWidget(
              backgroundColor: AppColors.stateGreen,
              text: 'Tạo dự án',
              onPressed: ()  {
                Navigator.pushNamed(context, '/general_info_project');
              },
            ),
          ],
        ),
      ),
    );
  }
}
