// This is a basic Flutter widget test for Kivora.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kivora_app/app.dart';

void main() {
  testWidgets('Kivora app renders welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KivoraApp()));

    // Verify that the app renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
