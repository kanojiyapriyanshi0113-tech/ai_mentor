// This is a basic Flutter widget smoke test for AI Mentor.
//
// It verifies the app boots and renders a MaterialApp without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AIMentorApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}