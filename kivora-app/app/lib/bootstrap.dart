import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/auth_service.dart';
import 'core/services/kivora_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check explicit mode parameter: 'live' (default) or 'demo'
  const appModeParam = String.fromEnvironment('APP_MODE', defaultValue: 'live');

  // Supabase URL resolution: checks SUPABASE_URL, FLUTTER_APP_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_URL
  const rawUrl = String.fromEnvironment('SUPABASE_URL');
  const rawFlutterUrl = String.fromEnvironment('FLUTTER_APP_SUPABASE_URL');
  const rawNextUrl = String.fromEnvironment('NEXT_PUBLIC_SUPABASE_URL');
  const fallbackUrl = 'https://bbgecpfqfoqlmzzbfeyu.supabase.co';

  const supabaseUrl = rawUrl != ''
      ? rawUrl
      : (rawFlutterUrl != ''
          ? rawFlutterUrl
          : (rawNextUrl != '' ? rawNextUrl : fallbackUrl));

  // Supabase Key resolution: accepts SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY
  // (also accepts FLUTTER_APP_SUPABASE_ANON_KEY and NEXT_PUBLIC_SUPABASE_ANON_KEY)
  const rawPublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  const rawAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const rawFlutterAnonKey = String.fromEnvironment('FLUTTER_APP_SUPABASE_ANON_KEY');
  const rawNextAnonKey = String.fromEnvironment('NEXT_PUBLIC_SUPABASE_ANON_KEY');
  const fallbackAnonKey = 'sb_publishable_0yRFU4h_VAVabc3av87VrQ_MFs8ntfy';

  const supabaseAnonKey = rawPublishableKey != ''
      ? rawPublishableKey
      : (rawAnonKey != ''
          ? rawAnonKey
          : (rawFlutterAnonKey != ''
              ? rawFlutterAnonKey
              : (rawNextAnonKey != '' ? rawNextAnonKey : fallbackAnonKey)));

  if (appModeParam.toLowerCase() == 'demo') {
    AuthService().setAppMode(AppMode.demo);
    AuthService().setLiveBackendConfigured(false);
    KivoraService().initializeDemoMode();
    debugPrint('[Kivora] Running in explicit DEMO MODE with isolated sample data.');
  } else {
    // Explicit LIVE Mode
    AuthService().setAppMode(AppMode.live);
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        AuthService().setLiveBackendConfigured(true);
        debugPrint('[Kivora] Supabase live backend initialized successfully for project: bbgecpfqfoqlmzzbfeyu ($supabaseUrl).');
      } catch (e) {
        AuthService().setLiveBackendConfigured(false);
        AuthService().setLiveInitError('Failed to connect to Supabase database: $e');
        debugPrint('[Kivora] Supabase connection failed in LIVE mode: $e');
      }
    } else {
      AuthService().setLiveBackendConfigured(false);
      AuthService().setLiveInitError(
        'Supabase credentials (SUPABASE_URL and SUPABASE_ANON_KEY or SUPABASE_PUBLISHABLE_KEY) are not configured via --dart-define.',
      );
      debugPrint('[Kivora] Live mode active but credentials not configured.');
    }

    // In LIVE mode, start with zero mock data
    KivoraService().initializeLiveMode();
  }

  // Restore any persisted draft or session
  try {
    await KivoraService().restorePersistedState();
  } catch (e) {
    debugPrint('[Kivora] Session restore warning: $e');
  }

  runApp(
    const ProviderScope(
      child: KivoraApp(),
    ),
  );
}
