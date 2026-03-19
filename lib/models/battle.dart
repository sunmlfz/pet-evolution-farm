import 'package:hive/hive.dart';
import 'pet.dart';

part 'battle.g.dart';

/// 野生怪物配置
class MonsterConfig {
  final String monsterId;
  final String name;
  final int level;
  final int hp;
  final int attackPower;
  final int defense;
  final int speed;
  final int expReward;
  final int goldReward;
  final Map<String, double> dropRates; // itemId -> 掉落概率
  final String spriteId;
  final String mapId;

  const MonsterConfig({
    required this.monsterId,
    required this.name,
    required this.level,
    required this.hp,
    required this.attackPower,
    required this.defense,
    required this.speed,
    required this.expReward,
    required this.goldReward,
    required this.dropRates,
    required this.spriteId,
    required this.mapId,
  });
}

/// 静态怪物配置表
const List<MonsterConfig> kMonsterConfigs = [
  MonsterConfig(
    monsterId: 'wild_rabbit',
    name: '野生兔子',
    level: 1,
    hp: 50,
    attackPower: 8,
    defense: 2,
    speed: 12,
    expReward: 30,
    goldReward: 15,
    dropRates: {'grass_herb': 0.5},
    spriteId: 'monster_rabbit',
    mapId: 'forest_1',
  ),
  MonsterConfig(
    monsterId: 'stone_crab',
    name: '石甲蟹',
    level: 3,
    hp: 120,
    attackPower: 15,
    defense: 10,
    speed: 5,
    expReward: 80,
    goldReward: 35,
    dropRates: {'iron_ore': 0.4, 'rare_egg': 0.05},
    spriteId: 'monster_crab',
    mapId: 'forest_1',
  ),
  MonsterConfig(
    monsterId: 'sand_scorpion',
    name: '沙漠蝎',
    level: 8,
    hp: 200,
    attackPower: 30,
    defense: 8,
    speed: 18,
    expReward: 200,
    goldReward: 80,
    dropRates: {'venom_sac': 0.6, 'special_egg': 0.02},
    spriteId: 'monster_scorpion',
    mapId: 'desert_1',
  ),
  MonsterConfig(
    monsterId: 'mountain_bear',
    name: '山岭熊',
    level: 15,
    hp: 500,
    attackPower: 50,
    defense: 25,
    speed: 8,
    expReward: 500,
    goldReward: 200,
    dropRates: {'bear_claw': 0.7, 'rare_egg': 0.1},
    spriteId: 'monster_bear',
    mapId: 'mountain_1',
  ),
];

/// 战斗动作类型
enum BattleActionType {
  NORMAL_ATTACK, // 普通攻击
  SKILL_ATTACK,  // 技能攻击
  DEFEND,        // 防御
  FLEE,          // 逃跑
}

/// 战斗回合记录
@HiveType(typeId: 6)
class BattleRound extends HiveObject {
  @HiveField(0)
  int roundNumber;

  @HiveField(1)
  int actionTypeIndex; // BattleActionType 索引

  @HiveField(2)
  int playerDamage;    // 玩家对怪物造成的伤害

  @HiveField(3)
  int monsterDamage;   // 怪物对玩家造成的伤害

  @HiveField(4)
  int playerHpLeft;    // 玩家宠物剩余HP

  @HiveField(5)
  int monsterHpLeft;   // 怪物剩余HP

  @HiveField(6)
  String? skillUsed;   // 使用的技能ID（若有）

  BattleRound({
    required this.roundNumber,
    required this.actionTypeIndex,
    required this.playerDamage,
    required this.monsterDamage,
    required this.playerHpLeft,
    required this.monsterHpLeft,
    this.skillUsed,
  });

  BattleActionType get actionType => BattleActionType.values[actionTypeIndex];
}

/// 战斗结果
class BattleResult {
  final bool playerWon;
  final int expGained;
  final int goldGained;
  final List<String> itemsDropped;
  final List<BattleRound> rounds;
  final int totalRounds;

  const BattleResult({
    required this.playerWon,
    required this.expGained,
    required this.goldGained,
    required this.itemsDropped,
    required this.rounds,
    required this.totalRounds,
  });
}

/// 回合制战斗引擎
class BattleEngine {
  /// 执行一场完整战斗
  static BattleResult fight({
    required Pet playerPet,
    required MonsterConfig monster,
  }) {
    final rounds = <BattleRound>[];
    int playerHp = playerPet.stats.maxHp;
    int monsterHp = monster.hp;
    int roundNum = 0;
    bool playerWon = false;

    // 根据速度决定先手
    final playerFirst = playerPet.stats.speed >= monster.speed;

    while (playerHp > 0 && monsterHp > 0 && roundNum < 30) {
      roundNum++;

      // 玩家选择动作（AI：优先使用技能，技能冷却中用普攻）
      final useSkill = playerPet.skills.isNotEmpty && roundNum % 3 == 0;
      final actionType =
          useSkill ? BattleActionType.SKILL_ATTACK : BattleActionType.NORMAL_ATTACK;

      int playerDamage = 0;
      int monsterDamage = 0;
      String? skillUsed;

      if (playerFirst) {
        // 玩家先手
        playerDamage = _calcPlayerDamage(playerPet, monster, actionType);
        monsterHp -= playerDamage;
        if (useSkill && playerPet.skills.isNotEmpty) {
          skillUsed = playerPet.skills[0].skillId;
        }
        if (monsterHp > 0) {
          monsterDamage = _calcMonsterDamage(monster, playerPet);
          playerHp -= monsterDamage;
        }
      } else {
        // 怪物先手
        monsterDamage = _calcMonsterDamage(monster, playerPet);
        playerHp -= monsterDamage;
        if (playerHp > 0) {
          playerDamage = _calcPlayerDamage(playerPet, monster, actionType);
          monsterHp -= playerDamage;
          if (useSkill && playerPet.skills.isNotEmpty) {
            skillUsed = playerPet.skills[0].skillId;
          }
        }
      }

      playerHp = playerHp.clamp(0, playerPet.stats.maxHp);
      monsterHp = monsterHp.clamp(0, monster.hp);

      rounds.add(BattleRound(
        roundNumber: roundNum,
        actionTypeIndex: actionType.index,
        playerDamage: playerDamage,
        monsterDamage: monsterDamage,
        playerHpLeft: playerHp,
        monsterHpLeft: monsterHp,
        skillUsed: skillUsed,
      ));
    }

    playerWon = monsterHp <= 0;

    // 计算奖励
    int expGained = playerWon ? monster.expReward : monster.expReward ~/ 5;
    int goldGained = playerWon ? monster.goldReward : 0;
    final itemsDropped = <String>[];
    if (playerWon) {
      for (final entry in monster.dropRates.entries) {
        // 简化随机（实际应用中用 dart:math Random）
        if (DateTime.now().millisecondsSinceEpoch % 100 < (entry.value * 100).toInt()) {
          itemsDropped.add(entry.key);
        }
      }
    }

    return BattleResult(
      playerWon: playerWon,
      expGained: expGained,
      goldGained: goldGained,
      itemsDropped: itemsDropped,
      rounds: rounds,
      totalRounds: roundNum,
    );
  }

  /// 计算玩家伤害
  static int _calcPlayerDamage(
      Pet pet, MonsterConfig monster, BattleActionType action) {
    double base = pet.stats.attackPower.toDouble();
    double multiplier = 1.0;

    if (action == BattleActionType.SKILL_ATTACK && pet.skills.isNotEmpty) {
      final skill = pet.skills[0];
      base += skill.damage + skill.proficiency * 0.1;
      multiplier = 1.5;
      // 使用技能提升熟练度
      skill.proficiency = (skill.proficiency + 1).clamp(0, 100);
    }

    final damage = ((base * multiplier) - monster.defense * 0.5).round();
    return damage.clamp(1, 9999);
  }

  /// 计算怪物伤害
  static int _calcMonsterDamage(MonsterConfig monster, Pet pet) {
    final damage = (monster.attackPower - pet.stats.defense * 0.5).round();
    return damage.clamp(1, 9999);
  }
}
