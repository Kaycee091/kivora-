import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
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
    );
  }
}
