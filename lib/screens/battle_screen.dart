import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/battle.dart';
import '../models/pet.dart';
import '../providers/game_provider.dart';
import '../systems/battle_system.dart';

/// 战斗界面
class BattleScreen extends ConsumerStatefulWidget {
  final Pet playerPet;
  final MonsterConfig monster;
  final String mapId;

  const BattleScreen({
    super.key,
    required this.playerPet,
    required this.monster,
    required this.mapId,
  });

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late BattleSession _session;
  int _currentRoundIndex = 0;
  bool _battleDone = false;
  int _playerHp = 0;
  int _monsterHp = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 创建战斗会话并执行
    _session = BattleSystem.startBattle(
      playerPet: widget.playerPet,
      monsterId: widget.monster.monsterId,
      mapId: widget.mapId,
    );
    _session.execute();
    _playerHp = widget.playerPet.stats.maxHp;
    _monsterHp = widget.monster.hp;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// 播放下一回合
  void _nextRound() {
    final rounds = _session.result.rounds;
    if (_currentRoundIndex >= rounds.length) {
      _finishBattle();
      return;
    }
    final round = rounds[_currentRoundIndex];
    setState(() {
      _playerHp = round.playerHpLeft;
      _monsterHp = round.monsterHpLeft;
      _currentRoundIndex++;
    });
    _animController.forward(from: 0);
  }

  /// 快速完成战斗
  void _skipToEnd() {
    final rounds = _session.result.rounds;
    if (rounds.isNotEmpty) {
      final last = rounds.last;
      setState(() {
        _playerHp = last.playerHpLeft;
        _monsterHp = last.monsterHpLeft;
        _currentRoundIndex = rounds.length;
      });
    }
    _finishBattle();
  }

  void _finishBattle() {
    setState(() => _battleDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final result = _session.result;
    final maxPlayerHp = widget.playerPet.stats.maxHp;
    final maxMonsterHp = widget.monster.hp;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('⚔️ ${widget.playerPet.name} vs ${widget.monster.name}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 怪物区域
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👾', style: TextStyle(fontSize: 72)),
                  Text(
                    widget.monster.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _HpBar(
                    current: _monsterHp,
                    max: maxMonsterHp,
                    color: Colors.red,
                    label: 'HP',
                  ),
                ],
              ),
            ),
          ),

          // 战斗回合信息
          if (!_battleDone && _currentRoundIndex > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Builder(builder: (_) {
                final round = result.rounds[_currentRoundIndex - 1];
                return Column(
                  children: [
                    Text(
                      '第 ${round.roundNumber} 回合',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '我方造成 ${round.playerDamage} 伤害  |  受到 ${round.monsterDamage} 伤害',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (round.skillUsed != null)
                      Text(
                        '使用了技能：${round.skillUsed}',
                        style: const TextStyle(color: Colors.yellow),
                      ),
                  ],
                );
              }),
            ),

          // 战斗结果
          if (_battleDone)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result.playerWon ? Colors.green.shade900 : Colors.red.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    result.playerWon ? '🎉 胜利！' : '💀 失败',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('经验 +${result.expGained}',
                      style: const TextStyle(color: Colors.yellow)),
                  if (result.goldGained > 0)
                    Text('金币 +${result.goldGained}',
                        style: const TextStyle(color: Colors.yellow)),
                  if (result.itemsDropped.isNotEmpty)
                    Text('获得物品: ${result.itemsDropped.join('、')}',
                        style: const TextStyle(color: Colors.lightGreenAccent)),
                ],
              ),
            ),

          // 玩家区域
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HpBar(
                    current: _playerHp,
                    max: maxPlayerHp,
                    color: Colors.green,
                    label: 'HP',
                  ),
                  const SizedBox(height: 8),
                  const Text('🐾', style: TextStyle(fontSize: 60)),
                  Text(
                    widget.playerPet.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 操作按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!_battleDone) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextRound,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text(_currentRoundIndex == 0
                            ? '开始战斗'
                            : '下一回合 (${_currentRoundIndex}/${result.rounds.length})'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _skipToEnd,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white),
                      child: const Text('跳过'),
                    ),
                  ] else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref.read(battleProvider.notifier).settle();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('确认结算'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HpBar extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final String label;

  const _HpBar({
    required this.current,
    required this.max,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('$current / $max',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white24,
            color: color,
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}
