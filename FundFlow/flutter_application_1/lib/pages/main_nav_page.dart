import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/transaksi_tab.dart'; // FILE BARU
import 'tabs/goals_tab.dart';
import 'tabs/insight_tab.dart';
import 'tabs/profile_tab.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardTab(),
    TransaksiTab(), // BARU
    GoalsTab(),
    InsightTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_outlined, 'Beranda', 0),
                _navItem(Icons.receipt_long_outlined, 'Transaksi', 1),
                _navItem(Icons.flag_outlined, 'Target', 2),
                _navItem(Icons.pie_chart_outline, 'Insight', 3),
                _navItem(Icons.person_outline, 'Profil', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isActive ? AppColors.primaryGreen : AppColors.textGrey),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 10, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primaryGreen : AppColors.textGrey
            )),
          ],
        ),
      ),
    );
  }
}