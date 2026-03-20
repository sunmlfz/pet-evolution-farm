import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/battle.dart';
import '../providers/game_provider.dart';
import '../systems/map_system.dart';
import '../systems/battle_system.dart';
import 'battle_screen.dart';

/// 地图探索界面
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _isExploring = false;
  String? _exploreMessage;
  String _currentMapId = 'forest_1';

  Future<void> _explore() async {
    final petsState = ref.read(petsProvider);
    final player = ref.read(playerProvider);

    // 检查是否有宠物
    if (petsState.isEmpty || player.activePetId == null) {
      setState(() => _exploreMessage = '没有出战宠物！请先设置出战宠物。');
      return;
    }

    final activePet = petsState.firstWhere(
      (p) => p.petId == player.activePetId,
      orElse: () => petsState.first,
    );

    if (!activePet.isHatched) {
      setState(() => _exploreMessage = '宠物还未孵化，无法出战！');
      return;
    }

    setState(() {
      _isExploring = true;
      _exploreMessage = null;
    });

    // 模拟探索延迟
    await Future.delayed(const Duration(seconds: 1));

    final event = MapSystem.explore(_currentMapId, activePet.level);

    if (!mounted) return;

    switch (event.type) {
      case ExploreEventType.BATTLE:
        // 随机怪物遭遇 → 跳转战斗界面
        final monster = kMonsterConfigs.firstWhere(
          (m) => m.monsterId == event.monsterId,
          orElse: () => kMonsterConfigs.first,
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BattleScreen(
              playerPet: activePet,
              monster: monster,
              mapId: _currentMapId,
            ),
          ),
        );
        break;

      case ExploreEventType.FIND_RESOURCE:
      case ExploreEventType.FIND_EGG:
        // 将物品加入背包
        event.resources.forEach((itemId, count) {
          player.addItem(itemId, count);
        });
        await ref.read(playerProvider.notifier).update(player);
        break;

      case ExploreEventType.NOTHING:
      case ExploreEventType.HIDDEN_TASK:
        break;
    }

    if (mounted) {
      setState(() {
        _isExploring = false;
        _exploreMessage = event.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    // final unlockedMaps = MapSystem.getUnlockedAreas(player.unlockedMapIds);
    final allMaps = MapSystem.getAllAreas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ 地图探索'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 地图选择 Tab
          Container(
            height: 56,
            color: Colors.green.shade50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: allMaps.length,
              itemBuilder: (ctx, i) {
                final map = allMaps[i];
                final isUnlocked = player.unlockedMapIds.contains(map.mapId);
                final isSelected = _currentMapId == map.mapId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(isUnlocked ? map.name : '🔒 ${map.name}'),
                    selected: isSelected && isUnlocked,
                    onSelected: isUnlocked
                        ? (v) {
                            if (v) setState(() => _currentMapId = map.mapId);
                          }
                        : null,
                  ),
                );
              },
            ),
          ),

          // 当前地图信息
          Expanded(
            child: Builder(builder: (_) {
              final currentMap =
                  allMaps.firstWhere((m) => m.mapId == _currentMapId);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 地图卡片
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              currentMap.terrain == 'forest'
                                  ? '🌲'
                                  : currentMap.terrain == 'desert'
                                      ? '🏜️'
                                      : '⛰️',
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentMap.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentMap.description,
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _InfoChip('推荐等级', 'Lv.${currentMap.minLevel}+'),
                                _InfoChip(
                                    '怪物数', '${currentMap.monsterIds.length}种'),
                                _InfoChip(
                                    '地形', currentMap.terrain),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 怪物列表
                    const Text('🐉 怪物',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...BattleSystem.getMonstersInMap(_currentMapId)
                        .map((m) => Card(
                              child: ListTile(
                                leading: const Text('👾',
                                    style: TextStyle(fontSize: 28)),
                                title: Text(m.name),
                                subtitle: Text('Lv.${m.level} | HP:${m.hp}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('⚔️ ${m.attackPower}'),
                                    Text('EXP +${m.expReward}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.green)),
                                  ],
                                ),
                              ),
                            )),

                    const SizedBox(height: 16),

                    // 探索消息
                    if (_exploreMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(_exploreMessage!),
                      ),
                  ],
                ),
              );
            }),
          ),

          // 探索按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isExploring ? null : _explore,
                  icon: _isExploring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.explore),
                  label: Text(_isExploring ? '探索中...' : '开始探索'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
