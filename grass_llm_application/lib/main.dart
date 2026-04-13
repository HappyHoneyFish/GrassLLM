// 文件路径: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 核心配置与主题
import 'core/theme.dart';

// 状态管理 Providers
import 'providers/user_provider.dart';
import 'providers/timeline_provider.dart';
import 'providers/chat_provider.dart';

// UI 页面
import 'ui/screens/splash_screen.dart';

void main() {
  // 确保 Flutter 引擎与底层平台绑定完成 (调用平台通道前必须加这句)
  WidgetsFlutterBinding.ensureInitialized();

  // 运行 App
  runApp(const GrasslandAgentApp());
}

class GrasslandAgentApp extends StatelessWidget {
  const GrasslandAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 MultiProvider 在顶层注入所有的状态管理大脑
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: '草业智能体',
        debugShowCheckedModeBanner: false, // 隐藏右上角的 Debug 标签
        theme: AppTheme.lightTheme, // 使用我们接下来会配置的极简主题
        // 初始页面指向启动页 (由启动页自动判断是否已初始化)
        home: const SplashScreen(),
      ),
    );
  }
}