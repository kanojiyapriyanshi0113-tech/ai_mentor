import "package:flutter/material.dart";

/// Generic placeholder screen for routes that exist in navigation but
/// have no real backend/data behind them yet. Used instead of a fake
/// screen with invented data - keeps the route real while being honest
/// that the feature isn't built yet.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Icons.hourglass_empty_rounded,
    this.message = "This section is coming soon.",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
