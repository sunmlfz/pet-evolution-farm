import 'package:hive/hive.dart';

part 'pet.g.dart';

/// 宠物蛋类型
enum EggType {
  COMMON,  // 普通蛋
  RARE,    // 稀有蛋
  SPECIAL, // 特殊蛋
}

/// 进化阶段
enum EvolutionStage {
  NONE,   // 未进化（初始）
  FIRST,  // 一阶进化
  SECOND, // 二阶进化
  FINAL,  // 最终进化
  RARE,   // 稀有进化（特殊条件触发）
}

/// 宠物技能
@HiveType(typeId: 1)
class PetSkill extends HiveObject {
  @HiveField(0)
  String skillId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int proficiency; // 熟练度 0-100

  @HiveField(4)
  int damage;

  @HiveField(5)
  String type; // attack / defense / special

  PetSkill({
    required this.skillId,
    required this.name,
    required this.description,
    this.proficiency = 0,
    required this.damage,
    required this.type,
  });
}

/// 宠物属性
@HiveType(typeId: 2)
class PetStats extends HiveObject {
  @HiveField(0)
  int strength;    // 力量

  @HiveField(1)
  int agility;     // 敏捷

  @HiveField(2)
  int intelligence; // 智力

  @HiveField(3)
  int endurance;   // 耐力

  @HiveField(4)
  int maxHp;       // 最大生命值

  @HiveField(5)
  int attackPower; // 攻击力

  @HiveField(6)
  int defense;     // 防御力

  @HiveField(7)
  int speed;       // 速度

  PetStats({
    this.strength = 10,
    this.agility = 10,
    this.intelligence = 10,
    this.endurance = 10,
    this.maxHp = 100,
    this.attackPower = 15,
    this.defense = 5,
    this.speed = 10,
  });

  /// 根据属性计算战斗力
  int get combatPower =>
      strength * 2 + agility * 2 + intelligence + endurance + attackPower * 3 + defense * 2;
}

/// 宠物核心数据模型
@HiveType(typeId: 3)
class Pet extends HiveObject {
  @HiveField(0)
  String petId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String species; // 物种（如：火焰兔、石甲龟）

  @HiveField(3)
  int eggTypeIndex; // EggType 索引

  @HiveField(4)
  int evolutionStageIndex; // EvolutionStage 索引

  @HiveField(5)
  int level;

  @HiveField(6)
  int experience;

  @HiveField(7)
  int evolutionPoints; // 进化点数

  @HiveField(8)
  PetStats stats;

  @HiveField(9)
  List<PetSkill> skills;

  @HiveField(10)
  int skillSlots; // 技能槽数量

  @HiveField(11)
  bool isHatched; // 是否已孵化

  @HiveField(12)
  int hatchTimeMs; // 孵化剩余时间（毫秒）

  @HiveField(13)
  Map<String, int> feedingHistory; // 喂食历史 {"ATTACK": 5, "DEFENSE": 3, "SKILL": 2}

  @HiveField(14)
  int battleCount; // 战斗次数

  @HiveField(15)
  int winCount;    // 胜利次数

  @HiveField(16)
  String spriteId; // 外观图标 ID

  Pet({
    required this.petId,
    required this.name,
    required this.species,
    this.eggTypeIndex = 0,
    this.evolutionStageIndex = 0,
    this.level = 1,
    this.experience = 0,
    this.evolutionPoints = 0,
    required this.stats,
    List<PetSkill>? skills,
    this.skillSlots = 2,
    this.isHatched = false,
    this.hatchTimeMs = 0,
    Map<String, int>? feedingHistory,
    this.battleCount = 0,
    this.winCount = 0,
    this.spriteId = 'default_pet',
  })  : skills = skills ?? [],
        feedingHistory = feedingHistory ?? {'ATTACK': 0, 'DEFENSE': 0, 'SKILL': 0};

  EggType get eggType => EggType.values[eggTypeIndex];
  EvolutionStage get evolutionStage => EvolutionStage.values[evolutionStageIndex];

  /// 经验值上限（当前等级）
  int get expToNextLevel => level * 100 + level * level * 10;

  /// 是否可以升级
  bool get canLevelUp => experience >= expToNextLevel && level < 50;

  /// 升级
  void levelUp() {
    if (!canLevelUp) return;
    experience -= expToNextLevel;
    level++;
    // 升级提升属性
    stats.strength += 2;
    stats.agility += 2;
    stats.intelligence += 1;
    stats.endurance += 2;
    stats.maxHp += 20;
    stats.attackPower += 3;
    stats.defense += 1;
    stats.speed += 1;
    // 每5级解锁新技能槽
    if (level % 5 == 0 && skillSlots < 6) {
      skillSlots++;
    }
  }

  /// 喂食记录（影响进化方向）
  void feed(String cropType, int amount) {
    feedingHistory[cropType] = (feedingHistory[cropType] ?? 0) + amount;
    // 根据喂食类型提升对应属性
    switch (cropType) {
      case 'ATTACK':
        stats.strength += amount;
        stats.attackPower += amount;
        break;
      case 'DEFENSE':
        stats.defense += amount;
        stats.endurance += amount;
        break;
      case 'SKILL':
        stats.intelligence += amount;
        // 提升随机技能熟练度
        if (skills.isNotEmpty) {
          skills.first.proficiency =
              (skills.first.proficiency + amount * 5).clamp(0, 100);
        }
        break;
    }
    evolutionPoints += amount * 2;
  }

  /// 战斗后获得经验
  void gainBattleExp(int exp, bool won) {
    experience += exp;
    evolutionPoints += won ? 10 : 3;
    battleCount++;
    if (won) winCount++;
    // 连续战斗增强攻击属性
    if (battleCount % 5 == 0) {
      stats.attackPower += 1;
    }
  }

  /// 主导喂食类型（决定进化方向）
  String get dominantFeedType {
    final max = feedingHistory.entries.reduce((a, b) => a.value > b.value ? a : b);
    return max.key;
  }
}
