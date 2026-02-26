import "package:flutter/material.dart";

class AppColours {
  //brand colours
  static const Color background = Color(0xFF210F37);
  static const Color primaryGold = Color(0xFFFFC44D);
  static const Color deepMagenta = Color(0xFF4F1C51);
  static const Color mintGreen = Color(0xFF13ECA4);
  static const Color white = Color(0xFFFFFFFF);

  //White mixed colours
  static Color getWhiteMix(Color color, double opacity) {
    return Color.alphaBlend(Colors.white.withOpacity(opacity), color);
  }
}
