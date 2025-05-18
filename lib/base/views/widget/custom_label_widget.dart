import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLabelWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const CustomLabelWidget({
    Key? key,
    required this.text,
    this.color = const Color(0xFF00722C),
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.only(bottom: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}
