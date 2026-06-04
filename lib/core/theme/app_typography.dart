import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(Color textColor, String language) {
    final bool isAr = language == 'ar';

    final headingFont = isAr
        ? GoogleFonts.alexandria
        : GoogleFonts.poppins;
    final bodyFont = isAr ? GoogleFonts.alexandria : GoogleFonts.poppins;

    // Line height adjustment for Arabic readability
    final double? arabicHeight = isAr ? 1.4 : null;

    return TextTheme(
      // Main Page Titles -> ExtraBold (800)
      displayLarge: headingFont(color: textColor, fontWeight: FontWeight.w800, height: arabicHeight),
      displayMedium: headingFont(color: textColor, fontWeight: FontWeight.w800, height: arabicHeight),
      displaySmall: headingFont(color: textColor, fontWeight: FontWeight.w800, height: arabicHeight),
      
      // Section Titles -> Bold (700)
      headlineLarge: headingFont(color: textColor, fontWeight: FontWeight.w700, height: arabicHeight),
      headlineMedium: headingFont(color: textColor, fontWeight: FontWeight.w700, height: arabicHeight),
      headlineSmall: headingFont(color: textColor, fontWeight: FontWeight.w700, height: arabicHeight),
      
      // Card Titles / Statistics -> SemiBold (600)
      titleLarge: headingFont(color: textColor, fontWeight: FontWeight.w600, height: arabicHeight),
      titleMedium: bodyFont(color: textColor, fontWeight: FontWeight.w600, height: arabicHeight),
      titleSmall: bodyFont(color: textColor, fontWeight: FontWeight.w600, height: arabicHeight),
      
      // Body Text -> Regular (400)
      bodyLarge: bodyFont(color: textColor, fontWeight: FontWeight.w400, height: arabicHeight),
      bodyMedium: bodyFont(color: textColor, fontWeight: FontWeight.w400, height: arabicHeight),
      bodySmall: bodyFont(color: textColor, fontWeight: FontWeight.w400, height: arabicHeight),
      
      // Buttons -> SemiBold (600)
      labelLarge: bodyFont(color: textColor, fontWeight: FontWeight.w600, height: arabicHeight),
      // Category Chips -> Medium (500)
      labelMedium: bodyFont(color: textColor, fontWeight: FontWeight.w500, height: arabicHeight),
      labelSmall: bodyFont(color: textColor, fontWeight: FontWeight.w500, height: arabicHeight),
    );
  }

  static TextStyle get monospace => GoogleFonts.jetBrainsMono();
}
