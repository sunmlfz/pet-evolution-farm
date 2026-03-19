import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/pet.dart';

/// 宠物系统 - 孵化、成长、技能管理
class PetSystem {
  static const _uuid = Uuid();
  static final _random = Random();

  /// 宠物蛋价格配置
  static const Map<EggType, int> kEggPrices = {
    EggType.COMMON: 100,
    EggType.RARE: 500,
    EggType.SPECIAL: 1000,
  };

  /// 宠物蛋孵化时间（毫秒）
  static const Map<EggType, int> kHatchTimeMs = {
    EggType.COMMON: 5 * 60 * 1000,      // 5分钟
    EggType.RARE: 30 * 60 * 1000,       // 30分钟
    EggType.SPECIAL: 2 * 60 * 60 * 1000, // 2小时
  };

  /// 各蛋种可孵出的物种配置
  static const Map<EggType, List<String>> kEggSpecies = {
    EggType.COMMON: ['fire_rabbit', 'water_turtle', 'wind_bird', 'earth_bear'],
    EggType.RARE: ['thunder_fox', 'ice_wolf', 'shadow_cat', 'crystal_deer'],
    EggType.SPECIAL: ['dragon_pup', 'phoenix_chick', 'unicorn_foal'],
  };

  /// 物种初始技能配置
  static const Map<String, List<Map<String, dynamic>>> kSpeciesSkills = {
    'fire_rabbit': [
      {'skillId': 'fire_kick', 'name': '火焰踢', 'damage': 20, 'type': 'attack'},
    ],
    'water_turtle': [
      {'skillId': 'water_shield', 'name': '水盾术', 'damage': 5, 'type': 'defense'},
    ],
    'wind_bird': [
      {'skillId': 'gust', 'name': '疾风爪', 'damage': 18, 'type': 'attack'},
    ],
    'earth_bear': [
      {'skillId': 'stone_slam', 'name': '岩石冲击', 'damage': 25, 'type': 'attack'},
    ],
    'thunder_fox': [
      {'skillId': 'thunder_fang', 'name': '雷牙', 'damage': 35, 'type': 'attack'},
      {'skillId': 'swift_dodge', 'name': '迅捷闪避', 'damage': 0, 'type': 'defense'},
    ],
    'ice_wolf': [
      {'skillId': 'ice_howl', 'name': '冰吼', 'damage': 30, 'type': 'attack'},
      {'skillId': 'frost_armor', 'name': '霜甲', 'damage': 0, 'type': 'defense'},
    ],
    'shadow_cat': [
      {'skillId': 'shadow_strike', 'name': '暗影突袭', 'damage': 40, 'type': 'attack'},
    ],
    'crystal_deer': [
      {'skillId': 'crystal_beam', 'name': '水晶光束', 'damage': 28, 'type': 'special'},
      {'skillId': 'healing_aura', 'name': '治愈光环', 'damage': -20, 'type': 'special'},
    ],
    'dragon_pup': [
      {'skillId': 'dragon_breath', 'name': '龙息', 'damage': 60, 'type': 'attack'},
      {'skillId': 'dragon_scale', 'name': '龙鳞护甲', 'damage': 0, 'type': 'defense'},
      {'skillId': 'dragon_roar', 'name': '龙吼', 'damage': 45, 'type': 'special'},
    ],
    'phoenix_chick': [
      {'skillId': 'phoenix_flame', 'name': '凤凰火焰', 'damage': 55, 'type': 'attack'},
      {'skillId': 'rebirth', 'name': '涅槃重生', 'damage': -50, 'type': 'special'},
    ],
    'unicorn_foal': [
      {'skillId': 'holy_lance', 'name': '圣矛', 'damage': 50, 'type': 'attack'},
      {'skillId': 'blessing', 'name': '祝福', 'damage': -30, 'type': 'special'},
      {'skillId': 'purify', 'name': '净化', 'damage': 0, 'type': 'special'},
    ],
  };

  /// 购买并创建宠物蛋（未孵化状态）
  static Pet createEgg(EggType eggType) {
    final eggId = _uuid.v4();
    return Pet(
      petId: eggId,
      name: '${_eggTypeName(eggType)}蛋',
      species: 'egg_${eggType.name.toLowerCase()}',
      eggTypeIndex: eggType.index,
      stats: _defaultStats(eggType),
      isHatched: false,
      hatchTimeMs: DateTime.now().millisecondsSinceEpoch + (kHatchTimeMs[eggType] ?? 0),
      spriteId: 'egg_${eggType.name.toLowerCase()}',
    );
  }

  /// 孵化宠物蛋（随机决定物种和初始属性）
  static Pet? hatch(Pet egg) {
    if (egg.isHatched) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < egg.hatchTimeMs) return null; // 孵化时间未到

    final eggType = egg.eggType;
    final species = _randomSpecies(eggType);
    final stats = _randomStats(eggType);
    final skills = _createSkills(species);

    egg.species = species;
    egg.name = _speciesName(species);
    egg.isHatched = true;
    egg.hatchTimeMs = 0;
    egg.stats = stats;
    egg.skills = skills;
    egg.spriteId = '${species}_none';

    return egg;
  }

  /// 随机选择物种
  static String _randomSpecies(EggType eggType) {
    final species = kEggSpecies[eggType] ?? ['fire_rabbit'];
    return species[_random.nextInt(species.length)];
  }

  /// 根据蛋类型创建默认属性
  static PetStats _defaultStats(EggType eggType) {
    int bonus;
    switch (eggType) {
      case EggType.COMMON:
        bonus = 0;
        break;
      case EggType.RARE:
        bonus = 10;
        break;
      case EggType.SPECIAL:
        bonus = 25;
        break;
    }
    return PetStats(
      strength: 10 + bonus,
      agility: 10 + bonus,
      intelligence: 10 + bonus,
      endurance: 10 + bonus,
      maxHp: 100 + bonus * 5,
      attackPower: 15 + bonus,
      defense: 5 + bonus ~/ 2,
      speed: 10 + bonus ~/ 2,
    );
  }

  /// 孵化时随机属性（在基础上浮动 ±20%）
  static PetStats _randomStats(EggType eggType) {
    final base = _defaultStats(eggType);
    int rand(int val) => val + _random.nextInt(val ~/ 5 + 1) - val ~/ 10;
    return PetStats(
      strength: rand(base.strength),
      agility: rand(base.agility),
      intelligence: rand(base.intelligence),
      endurance: rand(base.endurance),
      maxHp: rand(base.maxHp),
      attackPower: rand(base.attackPower),
      defense: rand(base.defense),
      speed: rand(base.speed),
    );
  }

  /// 创建技能列表
  static List<PetSkill> _createSkills(String species) {
    final configs = kSpeciesSkills[species] ?? [];
    return configs
        .map((c) => PetSkill(
              skillId: c['skillId'] as String,
              name: c['name'] as String,
              description: '${c['name']} 技能',
              damage: c['damage'] as int,
              type: c['type'] as String,
            ))
        .toList();
  }

  static String _eggTypeName(EggType type) {
    switch (type) {
      case EggType.COMMON:
        return '普通';
      case EggType.RARE:
        return '稀有';
      case EggType.SPECIAL:
        return '特殊';
    }
  }

  static String _speciesName(String species) {
    const names = {
      'fire_rabbit': '火焰兔',
      'water_turtle': '水晶龟',
      'wind_bird': '疾风鸟',
      'earth_bear': '岩石熊',
      'thunder_fox': '雷电狐',
      'ice_wolf': '冰霜狼',
      'shadow_cat': '暗影猫',
      'crystal_deer': '水晶鹿',
      'dragon_pup': '小龙崽',
      'phoenix_chick': '凤凰幼鸟',
      'unicorn_foal': '独角马驹',
    };
    return names[species] ?? species;
  }
}
