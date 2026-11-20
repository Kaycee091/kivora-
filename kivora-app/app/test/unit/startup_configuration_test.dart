import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivora_app/app.dart';
import 'package:kivora_app/core/services/auth_service.dart';

void main() {
  group('Startup Configuration & Supabase Credential Evaluation', () {
    setUp(() {
      AuthService().setAppMode(AppMode.live);
      AuthService().setLiveBackendConfigured(false);
    });

    testWidgets('Live mode displays warning banner when backend is unconfigured', (WidgetTester tester) async {
      AuthService().setAppMode(AppMode.live);
      AuthService().setLiveBackendConfigured(false);

      await tester.pumpWidget(
        const ProviderScope(
          child: KivoraApp(),
        ),
      );
      await tester.pump();

      expect(
        find.text('LIVE MODE: Supabase backend credentials are not configured.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('Live mode hides warning banner when backend is configured', (WidgetTester tester) async {
      AuthService().setAppMode(AppMode.live);
      AuthService().setLiveBackendConfigured(true);

      await tester.pumpWidget(
        const ProviderScope(
          child: KivoraApp(),
        ),
      );
      await tester.pump();

      expect(
        find.text('LIVE MODE: Supabase backend credentials are not configured.'),
        findsNothing,
      );
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });

    testWidgets('Demo mode displays demo banner instead of unconfigured banner', (WidgetTester tester) async {
      AuthService().setAppMode(AppMode.demo);
      AuthService().setLiveBackendConfigured(false);

      await tester.pumpWidget(
        const ProviderScope(
          child: KivoraApp(),
        ),
      );
      await tester.pump();

      expect(
        find.text('DEMO MODE: Using isolated sample data. Changes are not saved to database.'),
        findsOneWidget,
      );
      expect(
        find.text('LIVE MODE: Supabase backend credentials are not configured.'),
        findsNothing,
      );
    });

    test('AuthService signUp returns unconfigured result when live backend is not ready', () async {
      AuthService().setAppMode(AppMode.live);
      AuthService().setLiveBackendConfigured(false);

      final result = await AuthService().signUp(
        email: 'test@kivora.org',
        password: 'Password123',
        fullName: 'Test User',
      );

      expect(result.isSuccess, isFalse);
      expect(result.isUnconfigured, isTrue);
      expect(result.errorMessage, contains('Live Supabase backend is not configured'));
      expect(result.errorMessage, contains('SUPABASE_PUBLISHABLE_KEY'));
    });

    test('AuthService signInWithPassword returns unconfigured result when live backend is not ready', () async {
      AuthService().setAppMode(AppMode.live);
      AuthService().setLiveBackendConfigured(false);

      final result = await AuthService().signInWithPassword(
        email: 'test@kivora.org',
        password: 'Password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.isUnconfigured, isTrue);
      expect(result.errorMessage, contains('Live Supabase backend is not configured'));
      expect(result.errorMessage, contains('SUPABASE_PUBLISHABLE_KEY'));
    });
  });
}
