import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFloatingButton extends StatelessWidget {
  CustomFloatingButton({
    Key? key,
    this.alignment,
    this.backgroundColor,
    this.onTap,
    this.shape,
    this.width,
    this.height,
    this.decoration,
    this.child,
  }) : super(key: key);

  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final ShapeBorder? shape;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? AlignmentDirectional.center,
      child: fabWidget,
    )
        : fabWidget;
  }

  Widget get fabWidget => FloatingActionButton(
    backgroundColor: backgroundColor,
    onPressed: onTap,
    shape: shape ?? RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24.h),
    ),
    child: Container(
      alignment: Alignment.center,
      width: width ?? 0,
      height: height ?? 0,
      decoration: decoration ??
          BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(24.h),
          ),
      child: child,
    ),
  );
}
