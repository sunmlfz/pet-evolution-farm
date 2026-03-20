/// 药品效果类型
enum PotionEffectType {
  HP_RESTORE,   // 恢复生命值（百分比）
  ATK_BOOST,    // 永久提升攻击力
  DEF_BOOST,    // 永久提升防御力
  HP_BOOST,     // 永久提升最大生命值
}

/// 药品效果
class PotionEffect {
  final PotionEffectType type;
  final double value; // HP_RESTORE: 0.0~1.0 百分比；ATK/DEF/HP_BOOST: 绝对数值

  const PotionEffect({required this.type, required this.value});
}

/// 炼药配方
class PotionRecipe {
  final String potionId;
  final String name;
  final String description;
  final String emoji;
  final Map<String, int> ingredients; // {cropId: count}
  final PotionEffect effect;

  const PotionRecipe({
    required this.potionId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.ingredients,
    required this.effect,
  });
}

/// 静态炼药配方表（7种药品）
const List<PotionRecipe> kPotionRecipes = [
  PotionRecipe(
    potionId: 'minor_heal',
    name: '初级治疗药水',
    description: '恢复宠物30%最大生命值',
    emoji: '🧪',
    ingredients: {'lingzhi': 1},
    effect: PotionEffect(type: PotionEffectType.HP_RESTORE, value: 0.3),
  ),
  PotionRecipe(
    potionId: 'major_heal',
    name: '高级治疗药水',
    description: '恢复宠物70%最大生命值',
    emoji: '💊',
    ingredients: {'lingzhi': 1, 'gold_shield': 1},
    effect: PotionEffect(type: PotionEffectType.HP_RESTORE, value: 0.7),
  ),
  PotionRecipe(
    potionId: 'full_heal',
    name: '满血仙丹',
    description: '完全恢复宠物生命值',
    emoji: '🌟',
    ingredients: {'starlight': 1, 'lingzhi': 1},
    effect: PotionEffect(type: PotionEffectType.HP_RESTORE, value: 1.0),
  ),
  PotionRecipe(
    potionId: 'minor_atk',
    name: '攻击药水',
    description: '永久提升宠物攻击力+5',
    emoji: '🔴',
    ingredients: {'fire_pepper': 2},
    effect: PotionEffect(type: PotionEffectType.ATK_BOOST, value: 5),
  ),
  PotionRecipe(
    potionId: 'major_atk',
    name: '烈火战药',
    description: '永久提升宠物攻击力+15',
    emoji: '🔥',
    ingredients: {'iron_thorn': 1, 'fire_pepper': 1},
    effect: PotionEffect(type: PotionEffectType.ATK_BOOST, value: 15),
  ),
  PotionRecipe(
    potionId: 'minor_def',
    name: '防御药水',
    description: '永久提升宠物防御力+8',
    emoji: '🔵',
    ingredients: {'gold_shield': 2},
    effect: PotionEffect(type: PotionEffectType.DEF_BOOST, value: 8),
  ),
  PotionRecipe(
    potionId: 'major_def',
    name: '铁壁战药',
    description: '永久提升宠物防御+20、最大HP+50',
    emoji: '🛡️',
    ingredients: {'hard_wall': 1, 'gold_shield': 1},
    effect: PotionEffect(type: PotionEffectType.HP_BOOST, value: 50),
  ),
];
