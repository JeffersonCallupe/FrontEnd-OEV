import 'package:flutter/material.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/config/router/app_router.dart';
import 'package:oev_mobile_app/config/theme/app_theme.dart';

void main() async {
  await Environment.initEnvironment();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(authProvider.notifier).logout();
    final appRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'OEV App',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 0).getTheme(),
    );
  }
}


