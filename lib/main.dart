import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_theme.dart';
import 'package:well_paw/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const WellPawApp());
}

class WellPawApp extends StatelessWidget {
  const WellPawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellPaw',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
