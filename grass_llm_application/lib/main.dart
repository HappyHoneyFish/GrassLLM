// 文件路径: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/user_provider.dart';
import 'providers/timeline_provider.dart';
import 'providers/chat_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GrasslandAgentApp());
}

class GrasslandAgentApp extends StatelessWidget {
  const GrasslandAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: '草业智能体',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}