// 文件路径: lib/ui/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants.dart';
import 'init_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;


    final userProvider = context.read<UserProvider>();
    await userProvider.loadProfile();

    if (!mounted) return;


    if (userProvider.profile != null) {

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InitScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.grass_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              "智牧草业",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "小而美且精的草场管家",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}