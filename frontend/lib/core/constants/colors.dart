import 'package:flutter/material.dart';

class AppColours {
  // Brand colours
  static const Color background   = Color(0xFF1B0B3B);
  static const Color primaryGold  = Color(0xFFD9A577);
  static const Color deepMagenta  = Color(0xFF3B1B45);
  static const Color cardBg       = Color(0xFF2A1040);
  static const Color mintGreen    = Color(0xFF4CAF50);
  static const Color white        = Color(0xFFFFFFFF);

  // Status colours
  static const Color healthy      = Color(0xFF4CAF50);
  static const Color warning      = Color(0xFFF57F17);
  static const Color danger       = Color(0xFFC62828);
  static const Color overweight   = Color(0xFFE65100);

  // WHO chart zone colours
  static const Color whoSAM       = Color(0xFFB71C1C);   // below -3SD
  static const Color whoMAM       = Color(0xFFE65100);   // -3SD to -2SD
  static const Color whoModerate  = Color(0xFFF9A825);   // -2SD to -1SD
  static const Color whoNormal    = Color(0xFF1B5E20);   // -1SD to +1SD
  static const Color whoAbove     = Color(0xFF33691E);   // +1SD to +2SD
  static const Color whoOverwt    = Color(0xFFF57F17);   // +2SD to +3SD

  static Color getWhiteMix(Color color, double opacity) {
    return Color.alphaBlend(Colors.white.withOpacity(opacity), color);
  }
}