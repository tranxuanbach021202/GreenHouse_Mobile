import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/pref_utils.dart';



LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class ThemeHelper {
  final PrefUtils _prefUtils = PrefUtils();

  ThemeData get _appTheme => _prefUtils.getThemeData();

  Future<void> setAppTheme(ThemeData themeData) async {
    await _prefUtils.saveThemeData(themeData);
  }

// A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

// A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme = _supportedColorScheme[_appTheme] ??
        ColorSchemes.lightCodeColorScheme;

    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsetsDirectional.zero,
        ),
      ),
    );
  }

  LightCodeColors themeColor() => _getThemeColors();
  ThemeData themeData() => _getThemeData();
}
class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
    bodyMedium: TextStyle(
      color: colorScheme.onPrimary,
      fontSize: 14.sp,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      color: colorScheme.primary,
      fontSize: 32.sp,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w800,
    ),
    labelLarge: TextStyle(
      color: colorScheme.primary,
      fontSize: 12.sp,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: colorScheme.onPrimary,
      fontSize: 16.sp,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
  );
}


class LightCodeColors {
  Color get black900 => Color(0XFF000000);

  Color get deepOrange50 => Color(0XFFF9ECE9);

  Color get deepOrange500 => Color(0XFFFD6B22);

  Color get deepPurpleA400 => Color(0XFF5835FB);

  Color get whiteA700 => Color(0XFFFFFFFF);

  Color oldSilver = Color(0xFF868686);

  Color spanishGray = Color(0xFF979797);

  Color cultured = Color(0xFFF5F5F5);

  Color antiFlashWhite = Color(0xFFECF0F7);

  Color linen = Color(0xFFFBEDEB);

  Color skyBlue = Color(0xFF4EE2FF);

  Color bubBles = Color(0xFFE4FAFC);

  Color stateGreen = Color(0xFF093923);

  Color greyCloud = Color(0xFFB7B7B7);

  Color whiteSmoke = Color(0xFFF5F5F5);
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light(
    primary: Color(0xFF093923),
    primaryContainer: Color(0xFFB6B6B6),
    onPrimary: Color(0xFFF8F7F3),
  );
}