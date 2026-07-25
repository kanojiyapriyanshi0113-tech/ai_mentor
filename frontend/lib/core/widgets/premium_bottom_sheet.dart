import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../router/app_routes.dart";

Future<void> showPremiumBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(Icons.lock_outline, size: 40, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            const Text(
              "Upgrade to Continue",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              "You have reached the limit for your current plan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                sheetContext.push(AppRoutes.upgradePlan);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Monthly"),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                sheetContext.push(AppRoutes.upgradePlan);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Yearly"),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text("Later"),
            ),
          ],
        ),
      );
    },
  );
}