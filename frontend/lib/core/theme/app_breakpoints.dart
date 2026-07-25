import "package:flutter/material.dart";

/// Simple responsive breakpoints for adapting layouts across
/// phones, large phones/foldables, and tablets.
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compact && width < expanded;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= expanded;

  /// Returns a sensible grid column count based on available width.
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= expanded) return 4;
    if (width >= medium) return 3;
    return 2;
  }

  /// Returns horizontal page padding that scales with screen width.
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= expanded) return 48;
    if (width >= medium) return 32;
    return 20;
  }
}
