import "package:flutter/material.dart";

/// Animates a numeric value counting up from 0 (or its previous value)
/// whenever it changes. Used in overview/hero cards.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = "",
    this.suffix = "",
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          "$prefix${animatedValue.round()}$suffix",
          style: style,
        );
      },
    );
  }
}
