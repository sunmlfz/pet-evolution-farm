import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../providers/game_provider.dart';
import '../systems/evolution_system.dart';

/// 宠物详情页
class PetScreen extends ConsumerWidget {
  final Pet pet;
  const PetScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionProgress = EvolutionSystem.getEvolutionProgress(pet);
    final canEvolve = EvolutionSystem.canEvolve(pet);

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 宠物外观卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: 8),
                      Text(
                        pet.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${pet.species} · ${pet.evolutionStage.name}阶段',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      _EvolutionBadge(stage: pet.evolutionStage),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 等级和经验
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lv.${pet.level}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('EXP: ${pet.experience}/${pet.expToNextLevel}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pet.expToNextLevel > 0
                            ? pet.experience / pet.expToNextLevel
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blue,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 属性面板
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 属性',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _StatRow('⚔️ 力量', '${pet.stats.strength}'),
                    _StatRow('💨 敏捷', '${pet.stats.agility}'),
                    _StatRow('🧠 智力', '${pet.stats.intelligence}'),
                    _StatRow('🛡️ 耐力', '${pet.stats.endurance}'),
                    _StatRow('❤️ 生命值', '${pet.stats.maxHp}'),
                    _StatRow('💥 攻击力', '${pet.stats.attackPower}'),
                    _StatRow('🛡️ 防御', '${pet.stats.defense}'),
                    _StatRow('⚡ 速度', '${pet.stats.speed}'),
                    const Divider(),
                    _StatRow('🔥 综合战力', '${pet.stats.combatPower}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 技能列表
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✨ 技能 (${pet.skills.length}/${pet.skillSlots}槽)',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ...pet.skills.map((skill) => _SkillRow(skill: skill)),
                    if (pet.skills.isEmpty)
                      const Text('暂无技能', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 进化面板
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌟 进化',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('进化进度'),
                        Text('${(evolutionProgress * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: evolutionProgress,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.purple,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('进化点: ${pet.evolutionPoints}'),
                    Text(
                        '主导喂食方向: ${_feedTypeName(pet.dominantFeedType)}'),
                    if (canEvolve) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await ref
                                .read(petsProvider.notifier)
                                .evolve(pet.petId);
                            if (result != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.message)),
                              );
                            }
                          },
                          icon: const Text('🌟'),
                          label: const Text('立即进化！'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                    const Text('⚔️ 战斗记录',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _StatRow('战斗次数', '${pet.battleCount}'),
                    _StatRow('胜利次数', '${pet.winCount}'),
                    _StatRow('胜率',
                        '${pet.battleCount > 0 ? (pet.winCount / pet.battleCount * 100).toStringAsFixed(1) : 0}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _feedTypeName(String type) {
    switch (type) {
      case 'ATTACK':
        return '攻击型 ⚔️';
      case 'DEFENSE':
        return '防御型 🛡️';
      case 'SKILL':
        return '技能型 ✨';
      default:
        return '无';
    }
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
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final PetSkill skill;
  const _SkillRow({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(_skillTypeEmoji(skill.type), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                LinearProgressIndicator(
                  value: skill.proficiency / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.orange,
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('熟练:${skill.proficiency}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  String _skillTypeEmoji(String type) {
    switch (type) {
      case 'attack':
        return '⚔️';
      case 'defense':
        return '🛡️';
      case 'special':
        return '✨';
      default:
        return '🔮';
    }
  }
}

class _EvolutionBadge extends StatelessWidget {
  final EvolutionStage stage;
  const _EvolutionBadge({required this.stage});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (stage) {
      case EvolutionStage.NONE:
        color = Colors.grey;
        label = '未进化';
        break;
      case EvolutionStage.FIRST:
        color = Colors.green;
        label = '一阶';
        break;
      case EvolutionStage.SECOND:
        color = Colors.blue;
        label = '二阶';
        break;
      case EvolutionStage.FINAL:
        color = Colors.orange;
        label = '最终';
        break;
      case EvolutionStage.RARE:
        color = Colors.purple;
        label = '稀有★';
        break;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
