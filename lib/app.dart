import 'package:app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final themeData = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color.fromARGB(255, 51, 166, 94),
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      theme: themeData,
      routerConfig: appRouter,
    );
  }
}
