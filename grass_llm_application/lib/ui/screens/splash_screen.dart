// 文件路径: lib/ui/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../core/constants.dart';

// 引入即将开发的两个核心页面
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
    // 页面构建完成后立即执行初始化逻辑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // 强制展示至少 1.5 秒的启动页，避免本地读取过快导致画面闪烁
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 读取本地用户档案
    final userProvider = context.read<UserProvider>();
    await userProvider.loadProfile();

    if (!mounted) return;

    // 路由分发：基于是否已经存在本地档案
    if (userProvider.profile != null) {
      // 存在档案：直接进入全周期管理主页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // 不存在档案：进入无门槛初始化页
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
            // 极简风的占位 Logo
            const Icon(
              Icons.grass_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              "草业智能体",
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