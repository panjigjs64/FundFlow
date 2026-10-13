import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/simulation_provider.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_colors.dart';
import 'login_page.dart';
import 'main_nav_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final sim = context.read<SimulationProvider>();

    await auth.loadSession();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      sim.clearMemory();
      await sim.loadForUser(auth.currentUser!.id);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_fundflow.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 140,
                  height: 140,
                  child: Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'Fund',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                    TextSpan(
                      text: 'Flow',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}