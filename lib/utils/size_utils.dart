// import 'package:flutter/material.dart';
//
// const num FIGMA_DESIGN_WIDTH = 375;
// const num FIGMA_DESIGN_HEIGHT = 812;
// const num FIGMA_DESIGN_STATUS_BAR = 0;
//
//
// extension ResponsiveExtension on num {
//   double get _width => SizeUtils.width;
//
//   double get h => ((this * _width) / FIGMA_DESIGN_WIDTH);
//
//   double get fSize => ((this * _width) / FIGMA_DESIGN_WIDTH);
// }
//
// extension FormatExtension on double {
//   double toDoubleValue({int fractionDigits = 2}) {
//     return double.parse(this.toStringAsFixed(fractionDigits));
//   }
//
//   double isNonZero({num defaultValue = 0.0}) {
//     return this > 0 ? this : defaultValue.toDouble();
//   }
// }
//
// enum DeviceType { mobile, tablet, desktop }
//
// typedef ResponsiveBuild = Widget Function(
//     BuildContext context,
//     Orientation orientation,
//     DeviceType deviceType,
//     );
//
//
// class Sizer extends StatelessWidget {
//   const Sizer({Key? key, required this.builder}) : super(key: key);
//
//   final ResponsiveBuild builder;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return OrientationBuilder(
//           builder: (context, orientation) {
//             SizeUtils.setScreenSize(constraints, orientation);
//             return builder(context, orientation, SizeUtils.deviceType);
//           },
//         );
//       },
//     );
//   }
// }
//
//
// class SizeUtils {
//   /// BoxConstraints của thiết bị
//   static late BoxConstraints boxConstraints;
//
//   /// Orientation của thiết bị
//   static late Orientation orientation;
//
//   /// Loại thiết bị (mobile/tablet/desktop)
//   static late DeviceType deviceType;
//
//   /// Chiều cao của thiết bị
//   static late double height;
//
//   /// Chiều rộng của thiết bị
//   static late double width;
//
//   /// Thiết lập kích thước màn hình
//   static void setScreenSize(
//       BoxConstraints constraints,
//       Orientation currentOrientation,
//       ) {
//     boxConstraints = constraints;
//     orientation = currentOrientation;
//
//     if (orientation == Orientation.portrait) {
//       width = boxConstraints.maxWidth.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
//       height = boxConstraints.maxHeight.isNonZero();
//     } else {
//       width = boxConstraints.maxHeight.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
//       height = boxConstraints.maxWidth.isNonZero();
//     }
//
//     // Mặc định là mobile, bạn có thể bổ sung thêm logic nếu cần
//     deviceType = DeviceType.mobile;
//   }
// }
