import '../models/potion.dart';
import '../models/pet.dart';
import '../models/player.dart';

/// 炼药系统 - 合成药品、使用药品
class AlchemySystem {
  /// 检查是否可以合成指定药品
  static bool canCraft(PotionRecipe recipe, PlayerData player) {
    for (final entry in recipe.ingredients.entries) {
      if ((player.inventory[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }

  /// 合成药品
  static CraftResult craft(PotionRecipe recipe, PlayerData player) {
    if (!canCraft(recipe, player)) {
      return CraftResult(
        success: false,
        message: '材料不足：${_missingIngredients(recipe, player)}',
      );
    }
    // 消耗材料
    for (final entry in recipe.ingredients.entries) {
      player.consumeItem(entry.key, entry.value);
    }
    // 加入背包
    player.addItem(recipe.potionId, 1);
    return CraftResult(
      success: true,
      message: '合成成功！获得 ${recipe.emoji}${recipe.name}',
    );
  }

  /// 使用药品
  static UseResult usePotion(String potionId, PlayerData player, Pet pet) {
    if (!pet.isHatched) {
      return UseResult(success: false, message: '宠物尚未孵化');
    }
    if ((player.inventory[potionId] ?? 0) <= 0) {
      return UseResult(success: false, message: '背包中没有此药品');
    }

    PotionRecipe? recipe;
    try {
      recipe = kPotionRecipes.firstWhere((r) => r.potionId == potionId);
    } catch (e) {
      return UseResult(success: false, message: '未知药品: $potionId');
    }

    // 消耗药品
    player.consumeItem(potionId, 1);

    String message;
    switch (recipe.effect.type) {
      case PotionEffectType.HP_RESTORE:
        final healAmount = (pet.stats.maxHp * recipe.effect.value).round();
        final before = pet.stats.hp;
        pet.stats.hp = (pet.stats.hp + healAmount).clamp(0, pet.stats.maxHp);
        final actualHeal = pet.stats.hp - before;
        message = '${recipe.emoji}${recipe.name}：${pet.name} 恢复了 $actualHeal HP！'
            '（${pet.stats.hp}/${pet.stats.maxHp}）';
        break;
      case PotionEffectType.ATK_BOOST:
        pet.stats.attackPower += recipe.effect.value.round();
        message = '${recipe.emoji}${recipe.name}：${pet.name} 攻击力永久提升 +${recipe.effect.value.round()}！';
        break;
      case PotionEffectType.DEF_BOOST:
        pet.stats.defense += recipe.effect.value.round();
        message = '${recipe.emoji}${recipe.name}：${pet.name} 防御力永久提升 +${recipe.effect.value.round()}！';
        break;
      case PotionEffectType.HP_BOOST:
        pet.stats.maxHp += recipe.effect.value.round();
        pet.stats.defense += 20; // 铁壁战药额外+20防御
        pet.stats.hp = (pet.stats.hp + recipe.effect.value.round()).clamp(0, pet.stats.maxHp);
        message = '${recipe.emoji}${recipe.name}：${pet.name} 最大HP+${recipe.effect.value.round()} 防御+20！';
        break;
    }

    return UseResult(success: true, message: message);
  }

  /// 获取缺少的材料描述
  static String _missingIngredients(PotionRecipe recipe, PlayerData player) {
    final missing = <String>[];
    for (final entry in recipe.ingredients.entries) {
      final have = player.inventory[entry.key] ?? 0;
      if (have < entry.value) {
        missing.add('${entry.key} 需要${entry.value}个(拥有$have)');
      }
    }
    return missing.join('、');
  }

  /// 获取玩家可合成的配方列表
  static List<PotionRecipe> getAvailableRecipes(PlayerData player) {
    return kPotionRecipes.where((r) => canCraft(r, player)).toList();
  }

  /// 获取玩家拥有的药品列表
  static List<MapEntry<PotionRecipe, int>> getOwnedPotions(PlayerData player) {
    return kPotionRecipes
        .where((r) => (player.inventory[r.potionId] ?? 0) > 0)
        .map((r) => MapEntry(r, player.inventory[r.potionId]!))
        .toList();
  }
}

/// 合成结果
class CraftResult {
  final bool success;
  final String message;
  const CraftResult({required this.success, required this.message});
}

/// 使用结果
class UseResult {
  final bool success;
  final String message;
  const UseResult({required this.success, required this.message});
}
