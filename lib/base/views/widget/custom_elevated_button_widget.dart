import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';
import '../base_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButtonWidget extends BaseButton {
  CustomElevatedButtonWidget({
    Key? key,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    EdgeInsetsGeometry? margin,
    VoidCallback? onPressed,
    ButtonStyle? buttonStyle,
    AlignmentGeometry? alignment,
    TextStyle? buttonTextStyle,
    bool? isDisabled,
    double? height,
    double? width,
    required String text,
  }) : super(
    text: text,
    onPressed: onPressed,
    buttonStyle: buttonStyle,
    isDisabled: isDisabled,
    buttonTextStyle: buttonTextStyle,
    height: height,
    width: width,
    alignment: alignment,
    margin: margin,
  );

  final BoxDecoration? decoration;
  final Widget? leftIcon;
  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
        alignment: alignment ?? AlignmentDirectional.center,
        child: buildElevatedButtonWidget)
        : buildElevatedButtonWidget;
  }

  Widget get buildElevatedButtonWidget => Container(
    height: this.height ?? 50.h,
    width: this.width ?? double.maxFinite,
    margin: margin,
    decoration: decoration,
    child: ElevatedButton(
      style: buttonStyle,
      onPressed: isDisabled ?? false ? null : onPressed ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leftIcon ?? const SizedBox.shrink(),
          Text(
            text,
            style: buttonTextStyle ?? theme.textTheme.titleMedium,
          ),
          rightIcon ?? const SizedBox.shrink()
        ],
      ),
    ),
  );
}