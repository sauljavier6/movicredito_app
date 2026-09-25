import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'features/home/home_page.dart';

class MoviCreditoApp extends StatelessWidget {
  const MoviCreditoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviCrédito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: const HomePage(),
      builder: (context, child) => Banner(
        message: AppConfig.environmentLabel,
        location: BannerLocation.topEnd,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
