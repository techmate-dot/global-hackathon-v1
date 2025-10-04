import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/echoes_theme.dart';
import 'core/navigation/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/record_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EchoesApp());
}

class EchoesApp extends StatelessWidget {
  const EchoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => RecordProvider()),
      ],
      child: MaterialApp.router(
        title: 'Echoes',
        theme: EchoesTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
