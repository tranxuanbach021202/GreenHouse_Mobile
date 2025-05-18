

import 'package:flutter/material.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension IconButtonStyleHelper on CustomIconButton {
  static BoxDecoration get none => BoxDecoration();
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    this.alignment,
    this.height,
    this.width,
    this.decoration,
    this.padding,
    this.onTap,
    this.child,
  }) : super(key: key);

  final AlignmentGeometry? alignment;
  final double? height;
  final double? width;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment!,
      child: _iconButtonWidget,
    )
        : _iconButtonWidget;
  }

  Widget get _iconButtonWidget => SizedBox(
    height: height ?? 0,
    width: width ?? 0,
    child: DecoratedBox(
      decoration: decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(22.h),
            border: Border.all(
              color: AppColors.stateGreen,
              width: 1.h,
            ),
          ),
      child: IconButton(
        padding: padding ?? EdgeInsets.zero,
        onPressed: onTap,
        icon: child ?? const SizedBox(),
      ),
    ),
  );
}

