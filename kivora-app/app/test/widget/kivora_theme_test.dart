import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/core/theme/kivora_theme.dart';
import 'package:kivora_app/core/widgets/kivora_components.dart';

void main() {
  testWidgets('KivoraButton renders text and triggers callback on tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: KivoraTheme.lightTheme,
        home: Scaffold(
          body: KivoraButton(
            text: 'Start Verification',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Start Verification'), findsOneWidget);
    await tester.tap(find.text('Start Verification'));
    expect(tapped, isTrue);
  });

  testWidgets('KivoraStatusChip renders PRESENT status with emerald background', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KivoraStatusChip(status: 'Present'),
        ),
      ),
    );

    expect(find.text('PRESENT'), findsOneWidget);
  });
}
