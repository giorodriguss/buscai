import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_riverpod/flutter_riverpod.dart';
=======
>>>>>>> origin/develop
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'screens/figma_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init();
<<<<<<< HEAD
  runApp(const ProviderScope(child: BuscaiApp()));
=======
  runApp(const BuscaiApp());
>>>>>>> origin/develop
}

class BuscaiApp extends StatelessWidget {
  const BuscaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
