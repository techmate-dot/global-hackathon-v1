import 'package:flutter/material.dart';
import 'core/theme/echoes_theme.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(const EchoesApp());
}

class EchoesApp extends StatelessWidget {
  const EchoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Echoes',
      theme: EchoesTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
