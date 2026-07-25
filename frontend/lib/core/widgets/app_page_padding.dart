import "package:flutter/material.dart";

import "../theme/app_breakpoints.dart";

/// Wraps page content with responsive horizontal padding and an
/// optional max width so layouts don't stretch edge-to-edge on
/// tablets or large screens.
class AppPagePadding extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;

  const AppPagePadding({
    super.key,
    required this.child,
    this.maxContentWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppBreakpoints.pagePadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
