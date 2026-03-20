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

/// 静态怪物配置表（共20种）
const List<MonsterConfig> kMonsterConfigs = [
  // ===== 新手森林 (推荐Lv1-8) =====
  MonsterConfig(monsterId:'wild_rabbit',     name:'野生兔子',   level:1,  hp:60,   attackPower:10, defense:2,  speed:12, expReward:25,  goldReward:12,  dropRates:{'grass_herb':0.5},                    spriteId:'monster_rabbit',    mapId:'forest_1'),
  MonsterConfig(monsterId:'forest_boar',     name:'野猪',       level:2,  hp:90,   attackPower:14, defense:5,  speed:8,  expReward:40,  goldReward:18,  dropRates:{'boar_tusk':0.4},                     spriteId:'monster_boar',      mapId:'forest_1'),
  MonsterConfig(monsterId:'stone_crab',      name:'石甲蟹',     level:3,  hp:130,  attackPower:16, defense:12, speed:4,  expReward:65,  goldReward:30,  dropRates:{'iron_ore':0.4,'rare_egg':0.03},      spriteId:'monster_crab',      mapId:'forest_1'),
  MonsterConfig(monsterId:'green_snake',     name:'绿林蛇',     level:4,  hp:100,  attackPower:20, defense:6,  speed:16, expReward:80,  goldReward:35,  dropRates:{'snake_scale':0.5},                   spriteId:'monster_snake',     mapId:'forest_1'),
  MonsterConfig(monsterId:'wolf_pup',        name:'幼狼',       level:5,  hp:160,  attackPower:22, defense:8,  speed:14, expReward:100, goldReward:45,  dropRates:{'wolf_fang':0.3,'rare_egg':0.04},    spriteId:'monster_wolf',      mapId:'forest_1'),
  MonsterConfig(monsterId:'giant_spider',    name:'巨型蜘蛛',   level:6,  hp:140,  attackPower:25, defense:7,  speed:18, expReward:120, goldReward:50,  dropRates:{'spider_silk':0.6},                   spriteId:'monster_spider',    mapId:'forest_1'),
  MonsterConfig(monsterId:'forest_golem',    name:'树桩傀儡',   level:8,  hp:250,  attackPower:28, defense:18, speed:3,  expReward:160, goldReward:70,  dropRates:{'ancient_wood':0.4,'rare_egg':0.06}, spriteId:'monster_golem',     mapId:'forest_1'),
  // ===== 炎热沙漠 (推荐Lv5-15) =====
  MonsterConfig(monsterId:'sand_snake',      name:'沙漠游蛇',   level:5,  hp:120,  attackPower:28, defense:5,  speed:20, expReward:130, goldReward:55,  dropRates:{'venom_sac':0.4},                     spriteId:'monster_sand_snake',mapId:'desert_1'),
  MonsterConfig(monsterId:'desert_rat',      name:'沙漠鼠',     level:6,  hp:90,   attackPower:30, defense:4,  speed:22, expReward:110, goldReward:45,  dropRates:{'desert_bone':0.5},                   spriteId:'monster_desert_rat',mapId:'desert_1'),
  MonsterConfig(monsterId:'sand_scorpion',   name:'沙漠蝎',     level:8,  hp:200,  attackPower:35, defense:10, speed:12, expReward:190, goldReward:80,  dropRates:{'venom_sac':0.6,'special_egg':0.02}, spriteId:'monster_scorpion',  mapId:'desert_1'),
  MonsterConfig(monsterId:'cactus_golem',    name:'仙人掌怪',   level:10, hp:280,  attackPower:32, defense:20, speed:5,  expReward:240, goldReward:100, dropRates:{'cactus_spike':0.5},                  spriteId:'monster_cactus',    mapId:'desert_1'),
  MonsterConfig(monsterId:'sand_worm',       name:'沙地蠕虫',   level:12, hp:350,  attackPower:40, defense:12, speed:8,  expReward:300, goldReward:130, dropRates:{'worm_fluid':0.4,'rare_egg':0.08},   spriteId:'monster_worm',      mapId:'desert_1'),
  MonsterConfig(monsterId:'desert_phoenix',  name:'沙漠火鸟',   level:14, hp:320,  attackPower:50, defense:15, speed:25, expReward:380, goldReward:160, dropRates:{'phoenix_feather':0.3,'rare_egg':0.1},spriteId:'monster_phoenix',  mapId:'desert_1'),
  // ===== 险峻山岭 (推荐Lv12-25) =====
  MonsterConfig(monsterId:'rock_lizard',     name:'岩石蜥蜴',   level:12, hp:280,  attackPower:42, defense:18, speed:10, expReward:280, goldReward:110, dropRates:{'lizard_scale':0.5},                  spriteId:'monster_lizard',    mapId:'mountain_1'),
  MonsterConfig(monsterId:'mountain_eagle',  name:'山岭雄鹰',   level:14, hp:260,  attackPower:55, defense:12, speed:28, expReward:340, goldReward:140, dropRates:{'eagle_feather':0.4},                 spriteId:'monster_eagle',     mapId:'mountain_1'),
  MonsterConfig(monsterId:'mountain_bear',   name:'山岭熊',     level:15, hp:500,  attackPower:55, defense:28, speed:6,  expReward:450, goldReward:190, dropRates:{'bear_claw':0.7,'rare_egg':0.1},     spriteId:'monster_bear',      mapId:'mountain_1'),
  MonsterConfig(monsterId:'stone_troll',     name:'石头巨魔',   level:18, hp:650,  attackPower:65, defense:35, speed:4,  expReward:580, goldReward:240, dropRates:{'troll_stone':0.5,'rare_egg':0.12},  spriteId:'monster_troll',     mapId:'mountain_1'),
  MonsterConfig(monsterId:'ice_dragon',      name:'幼冰龙',     level:22, hp:900,  attackPower:80, defense:40, speed:15, expReward:800, goldReward:350, dropRates:{'dragon_scale':0.4,'special_egg':0.05},spriteId:'monster_ice_dragon',mapId:'mountain_1'),
  MonsterConfig(monsterId:'ancient_golem',   name:'远古傀儡',   level:25, hp:1200, attackPower:90, defense:50, speed:2,  expReward:1000,goldReward:500, dropRates:{'ancient_core':0.3,'special_egg':0.08},spriteId:'monster_ancient',  mapId:'mountain_1'),
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
    // 使用当前HP（持久化），而非满血开始战斗
    playerPet.stats.tickRegen(); // 先执行自然恢复
    int playerHp = playerPet.stats.currentHp;
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
        // 玩家先手：双方必然受伤（怪物惯性反击）
        playerDamage = _calcPlayerDamage(playerPet, monster, actionType);
        monsterHp -= playerDamage;
        if (useSkill && playerPet.skills.isNotEmpty) {
          skillUsed = playerPet.skills[0].skillId;
        }
        // 怪物即使死亡也有惯性伤害，确保每场战斗玩家HP必然减少
        monsterDamage = _calcMonsterDamage(monster, playerPet);
        playerHp -= monsterDamage;
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

    // HP持久化：将战斗最终HP写回宠物属性
    playerPet.stats.currentHp = playerHp.clamp(0, playerPet.stats.maxHp);
    playerPet.stats.lastRegenMs = DateTime.now().millisecondsSinceEpoch;

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

    if (action == BattleActionType.SKILL_ATTACK && pet.skills.isNotEmpty) {
      final skill = pet.skills[0];
      final profBonus = skill.proficiency * 0.15;
      base = base * 0.6 + skill.damage + profBonus;
      // 使用技能提升熟练度
      skill.proficiency = (skill.proficiency + 1).clamp(0, 100);
    } else {
      base = base * 0.8;
    }

    final damage = (base - monster.defense * 0.4).round();
    return damage.clamp(2, 9999);
  }

  /// 计算怪物伤害（最低保证2点，不可避免的惯性伤害）
  static int _calcMonsterDamage(MonsterConfig monster, Pet pet) {
    final rawDamage = (monster.attackPower * 0.85 - pet.stats.defense * 0.4).round();
    // 随机浮动 +0~4
    final variance = DateTime.now().millisecondsSinceEpoch % 5;
    return (rawDamage + variance).clamp(2, 9999);
  }
}
