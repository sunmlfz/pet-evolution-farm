import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'farm_screen.dart';
import 'pet_screen.dart';
import 'map_screen.dart';
import 'battle_screen.dart';

/// 主界面 - 底部导航栏切换四大核心界面
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _PetTab(),
    _FarmTab(),
    _MapTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 宠物进化田园'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          // 金币显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '${player.gold}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: '宠物'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: '农田'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '地图'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

// ===== 宠物 Tab =====
class _PetTab extends ConsumerWidget {
  const _PetTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final player = ref.watch(playerProvider);

    return Column(
      children: [
        // 购买宠物蛋区域
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EggButton(label: '普通蛋\n🪙100', onTap: () {
                // TODO: 调用 buyEgg(EggType.COMMON)
              }),
              _EggButton(label: '稀有蛋\n🪙500', onTap: () {
                // TODO: 调用 buyEgg(EggType.RARE)
              }),
              _EggButton(label: '特殊蛋\n🪙1000', onTap: () {
                // TODO: 调用 buyEgg(EggType.SPECIAL)
              }),
            ],
          ),
        ),
        // 宠物列表
        Expanded(
          child: pets.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🥚', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text('还没有宠物，快去购买宠物蛋吧！'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (ctx, i) => _PetCard(pet: pets[i]),
                ),
        ),
      ],
    );
  }
}

class _EggButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _EggButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _PetCard extends StatelessWidget {
  final pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Text('🐾', style: TextStyle(fontSize: 24)),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Lv.${pet.level} | ${pet.evolutionStage.name}'),
        trailing: Text('💪 ${pet.stats.combatPower}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PetScreen(pet: pet)),
          );
        },
      ),
    );
  }
}

// ===== 农田 Tab =====
class _FarmTab extends ConsumerWidget {
  const _FarmTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '农田 (${farm.unlockedPlots}/${Farm.kTotalPlots} 已解锁)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // 4×4 农田格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: Farm.kTotalPlots,
            itemBuilder: (ctx, i) => _FarmPlotWidget(
              plot: farm.plots[i],
              isUnlocked: i < farm.unlockedPlots,
            ),
          ),
        ),
        // 底部快捷操作
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 一键浇水所有已种植格子
                },
                icon: const Icon(Icons.water_drop),
                label: const Text('一键浇水'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 一键收割
                },
                icon: const Icon(Icons.agriculture),
                label: const Text('一键收割'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FarmPlotWidget extends StatelessWidget {
  final plot;
  final bool isUnlocked;
  const _FarmPlotWidget({required this.plot, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('🔒', style: TextStyle(fontSize: 20))),
      );
    }

    String emoji;
    Color color;
    switch (plot.status.index) {
      case 0: // EMPTY
        emoji = '🟫';
        color = Colors.brown.shade100;
        break;
      case 1: // PLANTED
        emoji = '🌱';
        color = Colors.green.shade100;
        break;
      case 2: // WATERED
        emoji = '💧';
        color = Colors.blue.shade100;
        break;
      case 3: // READY_TO_HARVEST
        emoji = '🌾';
        color = Colors.yellow.shade100;
        break;
      default:
        emoji = '🟫';
        color = Colors.brown.shade100;
    }

    return GestureDetector(
      onTap: () {
        // TODO: 显示操作菜单（种植/浇水/收割）
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown.shade300),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}

// ===== 地图 Tab =====
class _MapTab extends ConsumerWidget {
  const _MapTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🗺️ 地图探索',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // TODO: 根据 player.unlockedMapIds 渲染地图区域卡片
        _MapAreaCard(
          name: '新手森林',
          emoji: '🌲',
          description: '适合初学者的宁静森林',
          isUnlocked: player.unlockedMapIds.contains('forest_1'),
          onExplore: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _MapAreaCard(
          name: '炎热沙漠',
          emoji: '🏜️',
          description: '危险的沙漠，需要5级以上',
          isUnlocked: player.unlockedMapIds.contains('desert_1'),
          onExplore: () {},
        ),
        const SizedBox(height: 12),
        _MapAreaCard(
          name: '险峻山岭',
          emoji: '⛰️',
          description: '强大的山岭熊守卫，需要12级以上',
          isUnlocked: player.unlockedMapIds.contains('mountain_1'),
          onExplore: () {},
        ),
      ],
    );
  }
}

class _MapAreaCard extends StatelessWidget {
  final String name;
  final String emoji;
  final String description;
  final bool isUnlocked;
  final VoidCallback onExplore;

  const _MapAreaCard({
    required this.name,
    required this.emoji,
    required this.description,
    required this.isUnlocked,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 36)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isUnlocked
            ? ElevatedButton(onPressed: onExplore, child: const Text('探索'))
            : const Text('🔒 未解锁'),
        enabled: isUnlocked,
      ),
    );
  }
}

// ===== 我的 Tab =====
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 玩家头像卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF4CAF50),
                  child: Text('🧑‍🌾', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.nickname,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Lv.${player.level}'),
                    Text('ID: ${player.playerId.substring(0, 8)}...'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 资产信息
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💰 资产', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _StatRow('🪙 金币', '${player.gold}'),
                _StatRow('💎 宝石', '${player.gems}'),
                _StatRow('🥚 宠物数量', '${player.petIds.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 战斗统计
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚔️ 战斗统计', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _StatRow('总战斗次数', '${player.totalBattles}'),
                _StatRow('总胜利次数', '${player.totalWins}'),
                _StatRow('胜率', '${(player.winRate * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
