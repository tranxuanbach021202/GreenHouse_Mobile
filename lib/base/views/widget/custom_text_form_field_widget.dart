import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/colors.dart';
import '../../../core/theme/theme_helper.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  CustomTextFormFieldWidget({
    Key? key,
    this.alignment,
    this.width,
    this.boxDecoration,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = true,
    this.validator,
    this.borderRadius = 14.0, // Độ bo góc
    this.borderColor, // Màu viền mặc định
    this.focusedBorderColor, // Màu viền khi focus
  }) : super(key: key);

  final AlignmentGeometry? alignment;
  final double? width;
  final BoxDecoration? boxDecoration;
  final TextEditingController? controller;
  final TextEditingController? scrollPadding;
  final FocusNode? focusNode;
  final bool? autofocus;
  final bool? obscureText;
  final bool? readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final Widget? suffix;
  final BoxConstraints? prefixConstraints;
  final BoxConstraints? suffixConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor; // Màu border khi focus

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? AlignmentDirectional.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => Container(
    width: width ?? double.maxFinite,
    decoration: boxDecoration,
    child: TextFormField(
      scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) {
        focusNode?.unfocus();
      },
      autofocus: autofocus!,
      style: textStyle ?? theme.textTheme.bodyMedium,
      obscureText: obscureText!,
      readOnly: readOnly!,
      onTap: () => onTap?.call(),
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
    ),
  );

  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    hintStyle: hintStyle ?? theme.textTheme.bodyMedium,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? EdgeInsetsDirectional.all(12.r),
    fillColor: fillColor ?? AppColors.primaryColor,
    filled: filled,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius.r),
      borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius.r),
      borderSide: BorderSide(
        color: focusedBorderColor ?? AppColors.primaryColor, // Màu khi focus
        width: 1.5,
      ),
    ),
  );
}
