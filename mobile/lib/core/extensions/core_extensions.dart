import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;
  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  ThemeData get appTheme => Theme.of(this);
  MaterialColor get randomColor => Colors.primaries[Random().nextInt(17)];

  bool get isKeyBoardOpen => MediaQuery.of(this).viewInsets.bottom > 0;
  double get keyboardPadding => MediaQuery.of(this).viewInsets.bottom;
  Brightness get appBrightness => MediaQuery.of(this).platformBrightness;

  double get textScaleFactor => MediaQuery.of(this).textScaler.scale(1);
}

extension MediaQueryExtension on BuildContext {
  double get height => mediaQuery.size.height;
  double get width => mediaQuery.size.width;

  double get constXLowValue => 4;
  double get constLowValue => 8;
  double get constLow2xValue => 12;
  double get constMediumSValue => 14;
  double get constMediumValue => 15;
  double get constNormalValue => 16;
  double get constHighValue => 32;
  double get constExtraHighValue => 48;

  double get lowValue => height * 0.008;
  double get normalValue => height * 0.016;
  double get mediumValue => height * 0.032;
  double get highValue => height * 0.1;

  double dynamicWidth(double val) => width * val;
  double dynamicHeight(double val) => height * val;
}

extension DeviceOSExtension on BuildContext {
  bool get isAndroidDevice => Platform.isAndroid;
  bool get isIOSDevice => Platform.isIOS;
  bool get isWindowsDevice => Platform.isWindows;
  bool get isLinuxDevice => Platform.isLinux;
  bool get isMacOSDevice => Platform.isMacOS;
}

extension DurationExtension on BuildContext {
  Duration get durationLow => const Duration(milliseconds: 500);
  Duration get durationNormal => const Duration(seconds: 1);
  Duration get durationSlow => const Duration(seconds: 2);
}

extension PaddingExtension on BuildContext {
  EdgeInsets get nonPadding => EdgeInsets.zero;
  EdgeInsets get paddingLow => EdgeInsets.all(lowValue);
  EdgeInsets get paddingLow2x => EdgeInsets.all(constLow2xValue);
  EdgeInsets get paddingNormal => EdgeInsets.all(normalValue);
  EdgeInsets get paddingMedium => EdgeInsets.all(mediumValue);
  EdgeInsets get paddingHigh => EdgeInsets.all(highValue);

  EdgeInsets get paddingConstNormal => EdgeInsets.all(constNormalValue);
  EdgeInsets get horizontalPaddingConstNormal =>
      EdgeInsets.symmetric(horizontal: constNormalValue);
  EdgeInsets get horizontalPaddingConstLow =>
      EdgeInsets.symmetric(horizontal: constLowValue);
  EdgeInsets get verticalPaddingConstMedium =>
      EdgeInsets.symmetric(vertical: constMediumValue);
  EdgeInsets get verticalPaddingConstNormal =>
      EdgeInsets.symmetric(vertical: constNormalValue);
  EdgeInsets get verticalPaddingConstLow =>
      EdgeInsets.symmetric(vertical: constLowValue);
  EdgeInsets get horizontalPaddingConstNormalVertical14 => EdgeInsets.symmetric(
    horizontal: constNormalValue,
    vertical: constMediumSValue,
  );
  EdgeInsets get onlyTopHorizontalPaddingConstNormal => EdgeInsets.only(
    top: constNormalValue,
    left: constNormalValue,
    right: constNormalValue,
  );

  EdgeInsets get horizontalPaddingLow =>
      EdgeInsets.symmetric(horizontal: lowValue);
  EdgeInsets get horizontalPaddingNormal =>
      EdgeInsets.symmetric(horizontal: normalValue);
  EdgeInsets get horizontalPaddingMedium =>
      EdgeInsets.symmetric(horizontal: mediumValue);
  EdgeInsets get horizontalPaddingHigh =>
      EdgeInsets.symmetric(horizontal: highValue);

  EdgeInsets get verticalPaddingLow => EdgeInsets.symmetric(vertical: lowValue);
  EdgeInsets get verticalPaddingNormal =>
      EdgeInsets.symmetric(vertical: normalValue);
  EdgeInsets get verticalPaddingMedium =>
      EdgeInsets.symmetric(vertical: mediumValue);
  EdgeInsets get verticalPaddingHigh =>
      EdgeInsets.symmetric(vertical: highValue);

  EdgeInsets get onlyLeftPaddingLow => EdgeInsets.only(left: lowValue);
  EdgeInsets get onlyLeftPaddingNormal => EdgeInsets.only(left: normalValue);
  EdgeInsets get onlyLeftPaddingMedium => EdgeInsets.only(left: mediumValue);
  EdgeInsets get onlyLeftPaddingHigh => EdgeInsets.only(left: highValue);

  EdgeInsets get onlyRightPaddingLow => EdgeInsets.only(right: lowValue);
  EdgeInsets get onlyRightPaddingNormal => EdgeInsets.only(right: normalValue);
  EdgeInsets get onlyRightPaddingMedium => EdgeInsets.only(right: mediumValue);
  EdgeInsets get onlyRightPaddingHigh => EdgeInsets.only(right: highValue);

  EdgeInsets get onlyBottomPaddingLow => EdgeInsets.only(bottom: lowValue);
  EdgeInsets get onlyBottomPaddingNormal =>
      EdgeInsets.only(bottom: normalValue);
  EdgeInsets get onlyBottomPaddingMedium =>
      EdgeInsets.only(bottom: mediumValue);
  EdgeInsets get onlyBottomPaddingHigh => EdgeInsets.only(bottom: highValue);

  EdgeInsets get onlyTopPaddingLow => EdgeInsets.only(top: lowValue);
  EdgeInsets get onlyTopPaddingNormal => EdgeInsets.only(top: normalValue);
  EdgeInsets get onlyTopPaddingMedium => EdgeInsets.only(top: mediumValue);
  EdgeInsets get onlyTopPaddingHigh => EdgeInsets.only(top: highValue);
}

extension SizedBoxExtension on BuildContext {
  Widget get emptySizedBox => const SizedBox();
  Widget get emptySizedWidthBoxLow => const SizedBox(width: 0.01);
  Widget get emptySizedWidthBoxLow3x => const SizedBox(width: 0.03);
  Widget get emptySizedWidthBoxNormal => const SizedBox(width: 0.05);
  Widget get emptySizedWidthBoxHigh => const SizedBox(width: 0.1);

  Widget get emptySizedHeightBoxLow => const SizedBox(height: 0.01);
  Widget get emptySizedHeightBoxLow3x => const SizedBox(height: 0.03);
  Widget get emptySizedHeightBoxNormal => const SizedBox(height: 0.05);
  Widget get emptySizedHeightBoxHigh => const SizedBox(height: 0.1);
}

extension RadiusExtension on BuildContext {
  Radius get lowRadius => Radius.circular(width * 0.02);
  Radius get normalRadius => Radius.circular(width * 0.05);
  Radius get highRadius => Radius.circular(width * 0.1);
}

extension BorderExtension on BuildContext {
  BorderRadius get normalBorderRadius =>
      BorderRadius.all(Radius.circular(width * 0.05));

  BorderRadius get mediumBorderRadius =>
      BorderRadius.all(Radius.circular(constMediumValue));

  BorderRadius get xLowBorderRadius =>
      BorderRadius.all(Radius.circular(constXLowValue));

  BorderRadius get lowBorderRadius =>
      BorderRadius.all(Radius.circular(width * 0.02));
  BorderRadius get highBorderRadius =>
      BorderRadius.all(Radius.circular(width * 0.1));

  RoundedRectangleBorder get roundedRectangleBorderLow =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(lowValue)),
      );

  RoundedRectangleBorder get roundedRectangleAllBorderNormal =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(normalValue));

  RoundedRectangleBorder get roundedRectangleBorderNormal =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(normalValue)),
      );

  RoundedRectangleBorder get roundedRectangleBorderMedium =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(mediumValue)),
      );

  RoundedRectangleBorder get roundedRectangleBorderHigh =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(highValue)),
      );
}

extension SizedBoxNum on BuildContext {
  SizedBox get sizedHeightBoxLow => const SizedBox(height: 8);
  SizedBox get sizedHeightBoxLow2x => const SizedBox(height: 12);
  SizedBox get sizedHeightBoxNormal => const SizedBox(height: 16);
  SizedBox get sizedHeightBoxMedium => const SizedBox(height: 24);
  SizedBox get sizedHeightBoxHigh => const SizedBox(height: 32);

  SizedBox get sizedWidthBoxLow => const SizedBox(width: 8);
  SizedBox get sizedWidthBoxLow2x => const SizedBox(width: 12);
  SizedBox get sizedWidthBoxNormal => const SizedBox(width: 16);
  SizedBox get sizedWidthBoxMedium => const SizedBox(width: 24);
  SizedBox get sizedWidthBoxHigh => const SizedBox(width: 32);
}

extension AuthRegex on String {
  bool get isValidEmail => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(this);
  bool get isValidPassword =>
      length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(this) &&
      RegExp(r'[0-9]').hasMatch(this);
}

extension TextStyleExtension on BuildContext {
  TextStyle get headlineLarge => Theme.of(this).textTheme.displayLarge!;
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;
}

extension AppColorsContext on BuildContext {
  Color get cSurface => Theme.of(this).colorScheme.surface;
  Color get cBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get cTextPrimary => Theme.of(this).colorScheme.onSurface;
  Color get cPrimary => Theme.of(this).colorScheme.primary;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
