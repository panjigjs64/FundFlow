import 'package:flutter/material.dart';
import 'pages/loading_page.dart';

void main() {
  runApp(const FundFlowApp());
}

class FundFlowApp extends StatelessWidget {
  const FundFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FundFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoadingPage(),
    );
  }
}