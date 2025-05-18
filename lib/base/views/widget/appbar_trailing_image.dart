import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../screens/project_detail/custom_imageview.dart';

class AppbarTrailingImage extends StatelessWidget {
  const AppbarTrailingImage({
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
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        child: imagePath != null
            ? Image.asset(
          imagePath!,
          height: height ?? 30.0.h,
          width: width ?? 30.0.w,
          fit: BoxFit.contain,
        )
            : Container(),
      ),
    );
  }
}

