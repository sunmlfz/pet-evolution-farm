import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive 本地存储
  await Hive.initFlutter();

  // 注册 Hive Adapters
  // TODO: 运行 build_runner 生成 *.g.dart 文件后自动注册
  // Hive.registerAdapter(PetAdapter());
  // Hive.registerAdapter(PetStatsAdapter());
  // Hive.registerAdapter(PetSkillAdapter());
  // Hive.registerAdapter(FarmAdapter());
  // Hive.registerAdapter(FarmPlotAdapter());
  // Hive.registerAdapter(PlayerDataAdapter());
  // Hive.registerAdapter(BattleRoundAdapter());

  runApp(
    // Riverpod 状态管理根容器
    const ProviderScope(
      child: PetEvolutionFarmApp(),
    ),
  );
}

class PetEvolutionFarmApp extends StatelessWidget {
  const PetEvolutionFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宠物进化田园',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // 绿色主题（田园风）
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
