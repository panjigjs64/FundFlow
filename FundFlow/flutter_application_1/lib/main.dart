import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/loading_page.dart';
import 'providers/auth_provider.dart';
import 'providers/simulation_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
      ],
      child: const FundFlowApp(),
    ),
  );
}

class FundFlowApp extends StatelessWidget {
  const FundFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'FundFlow',
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoadingPage(),
    );
  }
}