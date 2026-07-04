import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2158D8);
  static const primaryDark = Color(0xFF16357F);

  static const pageBgTop = Color(0xFFEEF2F9);
  static const pageBgBottom = Color(0xFFDFE4EE);
  static const cardBorder = Color(0xFFECEFF4);
  static const cardBorderLight = Color(0xFFEEF1F6);
  static const divider = Color(0xFFF3F5F9);
  static const surfaceTint = Color(0xFFFAFBFF);
  static const chipBg = Color(0xFFF1F4F9);

  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF8A94A6);
  static const textMuted = Color(0xFF98A2B3);
  static const textFaint = Color(0xFFC2CAD6);

  static const lewatBar = Color(0xFFDC2626);
  static const lewatFg = Color(0xFFB42318);
  static const lewatBg = Color(0xFFFDECEC);

  static const segeraBar = Color(0xFFE8890C);
  static const segeraFg = Color(0xFFB25E09);
  static const segeraBg = Color(0xFFFFF4E5);

  static const amanBar = Color(0xFF16A34A);
  static const amanFg = Color(0xFF0F7A3D);
  static const amanBg = Color(0xFFE6F6EE);

  static const menungguFg = Color(0xFFB25E09);
  static const menungguBg = Color(0xFFFFF4E5);
  static const dikonfirmasiFg = Color(0xFF1D4ED8);
  static const dikonfirmasiBg = Color(0xFFE9F0FF);
  static const dikerjakanFg = Color(0xFF6D28D9);
  static const dikerjakanBg = Color(0xFFEFE9FF);
  static const selesaiFg = Color(0xFF0F7A3D);
  static const selesaiBg = Color(0xFFE6F6EE);
  static const batalFg = Color(0xFFB42318);
  static const batalBg = Color(0xFFFDECEC);

  static const saranBg1 = Color(0xFFFFF8ED);
  static const saranBg2 = Color(0xFFFFF3E0);
  static const saranBorder = Color(0xFFFCE3BB);
  static const saranIconBg = Color(0xFFFBE3B8);
  static const saranIconFg = Color(0xFFB25E09);
  static const saranTitle = Color(0xFF7A4405);
  static const saranText = Color(0xFF6B4A18);

  static const ratingStar = Color(0xFFF5A623);

  static Color primaryTint(double opacity) =>
      Color.lerp(Colors.white, primary, opacity) ?? primary;
}
