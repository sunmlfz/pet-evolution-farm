import '../models/pet.dart';

/// 进化条件定义
class EvolutionCondition {
  final int minLevel;
  final int minEvolutionPoints;
  final int minBattleCount;
  final String dominantFeedType;
  final EvolutionStage targetStage;
  final bool isRare;

  const EvolutionCondition({
    required this.minLevel,
    required this.minEvolutionPoints,
    required this.minBattleCount,
    required this.dominantFeedType,
    required this.targetStage,
    this.isRare = false,
  });
}

/// 进化系统
class EvolutionSystem {
  /// 进化条件配置
  static const List<EvolutionCondition> kEvolutionConditions = [
    // NONE -> FIRST: 3级，20进化点，3次战斗（降低门槛，让玩家更快体验进化）
    EvolutionCondition(
      minLevel: 3,
      minEvolutionPoints: 20,
      minBattleCount: 3,
      dominantFeedType: '',
      targetStage: EvolutionStage.FIRST,
    ),
    // FIRST -> SECOND: 8级，80进化点，10次战斗
    EvolutionCondition(
      minLevel: 8,
      minEvolutionPoints: 80,
      minBattleCount: 10,
      dominantFeedType: '',
      targetStage: EvolutionStage.SECOND,
    ),
    // SECOND -> FINAL: 15级，200进化点，25次战斗
    EvolutionCondition(
      minLevel: 15,
      minEvolutionPoints: 200,
      minBattleCount: 25,
      dominantFeedType: '',
      targetStage: EvolutionStage.FINAL,
    ),
    // FINAL -> RARE（特殊条件：稀有蛋 + 技能主导喂食 + 20次胜利 + 500进化点）
    EvolutionCondition(
      minLevel: 20,
      minEvolutionPoints: 500,
      minBattleCount: 20,
      dominantFeedType: 'SKILL',
      targetStage: EvolutionStage.RARE,
      isRare: true,
    ),
  ];

  /// 检查宠物是否满足进化条件
  static bool canEvolve(Pet pet) {
    final currentStage = pet.evolutionStage;

    // RARE 进化特殊检查
    if (currentStage == EvolutionStage.FINAL) {
      return _checkRareEvolution(pet);
    }

    // 普通进化：根据当前阶段找下一阶段条件
    final targetStage = _nextStage(currentStage);
    if (targetStage == null) return false;

    final condition = kEvolutionConditions
        .where((c) => c.targetStage == targetStage && !c.isRare)
        .firstOrNull;
    if (condition == null) return false;

    return pet.level >= condition.minLevel &&
        pet.evolutionPoints >= condition.minEvolutionPoints &&
        pet.battleCount >= condition.minBattleCount;
  }

  /// 检查稀有进化条件
  static bool _checkRareEvolution(Pet pet) {
    final rareCondition = kEvolutionConditions
        .firstWhere((c) => c.isRare, orElse: () => throw Exception('No rare condition'));
    return pet.eggType == EggType.RARE &&
        pet.winCount >= rareCondition.minBattleCount &&
        pet.evolutionPoints >= rareCondition.minEvolutionPoints &&
        pet.dominantFeedType == 'SKILL';
  }

  /// 执行进化
  static EvolutionResult evolve(Pet pet) {
    if (!canEvolve(pet)) {
      return EvolutionResult(
        success: false,
        message: '进化条件未满足',
        pet: pet,
      );
    }

    final currentStage = pet.evolutionStage;
    EvolutionStage newStage;
    String spriteId = pet.spriteId;

    if (currentStage == EvolutionStage.FINAL && _checkRareEvolution(pet)) {
      newStage = EvolutionStage.RARE;
      spriteId = '${pet.species}_rare';
    } else {
      newStage = _nextStage(currentStage)!;
      spriteId = '${pet.species}_${newStage.name.toLowerCase()}';
    }

    // 进化时属性大幅提升
    final bonuses = _calcEvolutionBonuses(newStage, pet.dominantFeedType);
    pet.stats.strength += bonuses['strength']!;
    pet.stats.agility += bonuses['agility']!;
    pet.stats.intelligence += bonuses['intelligence']!;
    pet.stats.endurance += bonuses['endurance']!;
    pet.stats.maxHp += bonuses['maxHp']!;
    pet.stats.attackPower += bonuses['attackPower']!;
    pet.stats.defense += bonuses['defense']!;

    // 解锁新技能槽
    if (pet.skillSlots < 6) pet.skillSlots++;

    // 更新进化阶段
    pet.evolutionStageIndex = newStage.index;
    pet.spriteId = spriteId;
    pet.evolutionPoints = 0; // 重置进化点

    return EvolutionResult(
      success: true,
      message: '进化成功！${pet.name} 进化为 ${newStage.name} 阶段！',
      pet: pet,
      newStage: newStage,
    );
  }

  /// 计算进化属性加成（根据进化阶段 + 主导喂食方向）
  static Map<String, int> _calcEvolutionBonuses(
      EvolutionStage stage, String dominantFeedType) {
    int multiplier;
    switch (stage) {
      case EvolutionStage.FIRST:
        multiplier = 1;
        break;
      case EvolutionStage.SECOND:
        multiplier = 3;
        break;
      case EvolutionStage.FINAL:
        multiplier = 8;
        break;
      case EvolutionStage.RARE:
        multiplier = 15;
        break;
      default:
        multiplier = 0;
    }

    final base = {
      'strength': 5 * multiplier,
      'agility': 5 * multiplier,
      'intelligence': 5 * multiplier,
      'endurance': 5 * multiplier,
      'maxHp': 50 * multiplier,
      'attackPower': 8 * multiplier,
      'defense': 3 * multiplier,
    };

    // 根据主导喂食方向额外加成
    switch (dominantFeedType) {
      case 'ATTACK':
        base['strength'] = base['strength']! + 10 * multiplier;
        base['attackPower'] = base['attackPower']! + 15 * multiplier;
        break;
      case 'DEFENSE':
        base['defense'] = base['defense']! + 10 * multiplier;
        base['endurance'] = base['endurance']! + 10 * multiplier;
        base['maxHp'] = base['maxHp']! + 100 * multiplier;
        break;
      case 'SKILL':
        base['intelligence'] = base['intelligence']! + 15 * multiplier;
        base['agility'] = base['agility']! + 10 * multiplier;
        break;
    }

    return base;
  }

  /// 获取下一进化阶段
  static EvolutionStage? _nextStage(EvolutionStage current) {
    switch (current) {
      case EvolutionStage.NONE:
        return EvolutionStage.FIRST;
      case EvolutionStage.FIRST:
        return EvolutionStage.SECOND;
      case EvolutionStage.SECOND:
        return EvolutionStage.FINAL;
      case EvolutionStage.FINAL:
      case EvolutionStage.RARE:
        return null;
    }
  }

  /// 获取进化进度（0.0 ~ 1.0）
  static double getEvolutionProgress(Pet pet) {
    final currentStage = pet.evolutionStage;
    final targetStage = _nextStage(currentStage);
    if (targetStage == null) return 1.0;

    final condition = kEvolutionConditions
        .where((c) => c.targetStage == targetStage && !c.isRare)
        .firstOrNull;
    if (condition == null) return 0.0;

    final levelProgress = pet.level / condition.minLevel;
    final pointProgress = pet.evolutionPoints / condition.minEvolutionPoints;
    final battleProgress = pet.battleCount / condition.minBattleCount;

    return ((levelProgress + pointProgress + battleProgress) / 3).clamp(0.0, 1.0);
  }
}

/// 进化结果
class EvolutionResult {
  final bool success;
  final String message;
  final Pet pet;
  final EvolutionStage? newStage;

  const EvolutionResult({
    required this.success,
    required this.message,
    required this.pet,
    this.newStage,
  });
}
