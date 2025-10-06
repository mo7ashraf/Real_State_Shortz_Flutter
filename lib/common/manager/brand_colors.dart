import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shortzz/common/widget/dominant_color.dart';
import 'package:shortzz/utilities/color_res.dart' as defaults;

class BrandColors {
  static Color primary = defaults.ColorRes.themeColor;
  static Color accent = defaults.ColorRes.themeAccentSolid;
  static Color gradient1 = defaults.ColorRes.themeGradient1;
  static Color gradient2 = defaults.ColorRes.themeGradient2;

  static Future<void> initFromAsset({
    String assetPath = 'assets/branding/aqar_shorts_icon_1024.png',
  }) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final extractor = DominantColors(bytes: bytes, dominantColorsCount: 2);
      final colors = extractor.extractDominantColors();
      if (colors.isNotEmpty) {
        // Pick two dominant colors; ensure stable ordering
        gradient1 = colors.first;
        gradient2 = colors.length > 1 ? colors[1] : colors.first;
        // Use the first as accent, and a darker variant as primary canvas
        accent = gradient1;
        primary = _darken(gradient1, 0.85);
      }
    } catch (_) {
      // Keep defaults on any error
    }
  }

  static Color _darken(Color c, double factor) {
    factor = factor.clamp(0.0, 1.0);
    final r = (c.red * factor).toInt();
    final g = (c.green * factor).toInt();
    final b = (c.blue * factor).toInt();
    return Color.fromARGB(c.alpha, r, g, b);
  }
}

