import 'package:flutter/material.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../screens/project_detail/custom_imageview.dart';
import 'custom_icon_button.dart';

class AppbarLeadingIconButton extends StatelessWidget {
  const AppbarLeadingIconButton({
    Key? key,
    this.imagePath,
    this.height,
    this.width,
    this.onTap,
    this.margin,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? imagePath;
  final Function? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: CustomIconButton(
          height: height ?? 70.h,
          width: width ?? 70.w,
          decoration: IconButtonStyleHelper.none,
          child: imagePath != null
              ? Image.asset(
            imagePath!,
            height: height ?? 70.h,
            width: width ?? 70.w,
          )
              : Container(),
        ),
      ),
    );
  }
}
