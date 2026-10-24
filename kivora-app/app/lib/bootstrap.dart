import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/auth_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if credentials are provided via --dart-define
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bbgecpfqfoqlmzzbfeyu.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      AuthService().setLiveBackendConfigured(true);
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      AuthService().setLiveBackendConfigured(false);
      debugPrint('Failed to initialize Supabase: $e (Falling back to offline/mock demo mode)');
    }
  } else {
    AuthService().setLiveBackendConfigured(false);
    debugPrint('Supabase credentials not configured. Running in offline/mock demo mode.');
  }

  runApp(
    const ProviderScope(
      child: KivoraApp(),
    ),
  );
}
