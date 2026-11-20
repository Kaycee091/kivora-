import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/theme/kivora_theme.dart';

class KivoraApp extends ConsumerWidget {
  const KivoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Kivora',
      debugShowCheckedModeBanner: false,
      theme: KivoraTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: AuthService(),
          builder: (context, _) {
            final isDemo = AuthService().isDemoMode;
            final isLiveUnconfigured = AuthService().isLiveMode && !AuthService().isLiveBackendConfigured;

            return Column(
              children: [
                if (isDemo)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFD97706),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: const SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.science_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'DEMO MODE: Using isolated sample data. Changes are not saved to database.',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isLiveUnconfigured)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: const SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'LIVE MODE: Supabase backend credentials are not configured.',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        );
      },
    );
  }
}
