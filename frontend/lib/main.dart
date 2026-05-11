import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'screens/figma_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init();
  runApp(const BuscaiApp());
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
