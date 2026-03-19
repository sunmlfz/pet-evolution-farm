import '../models/farm.dart';
import '../models/crop.dart';
import '../models/player.dart';
import '../models/pet.dart';

/// 农田系统 - 种植、浇水、收割、喂养
class FarmSystem {
  /// 种植作物（消耗种子）
  static bool plant({
    required Farm farm,
    required PlayerData player,
    required int plotIndex,
    required String cropId,
  }) {
    // 检查玩家是否有种子
    final seedId = '${cropId}_seed';
    if (!player.consumeItem(seedId, 1)) {
      return false; // 种子不足
    }

    return farm.plant(plotIndex, cropId);
  }

  /// 浇水
  static bool water({
    required Farm farm,
    required int plotIndex,
  }) {
    return farm.water(plotIndex);
  }

  /// 收割并将作物加入玩家背包
  static Map<String, int> harvest({
    required Farm farm,
    required PlayerData player,
    required int plotIndex,
  }) {
    final result = farm.harvest(plotIndex);
    result.forEach((cropId, count) {
      player.addItem(cropId, count);
    });
    return result;
  }

  /// 收割全部并加入背包
  static Map<String, int> harvestAll({
    required Farm farm,
    required PlayerData player,
  }) {
    final result = farm.harvestAll();
    result.forEach((cropId, count) {
      player.addItem(cropId, count);
    });
    return result;
  }

  /// 用作物喂养宠物（消耗背包中的作物）
  static FeedResult feedPet({
    required PlayerData player,
    required Pet pet,
    required String cropId,
    required int amount,
  }) {
    if (!pet.isHatched) {
      return FeedResult(success: false, message: '宠物尚未孵化');
    }

    // 检查背包中的作物数量
    final available = player.getItemCount(cropId);
    if (available < amount) {
      return FeedResult(success: false, message: '作物不足，拥有 $available 个');
    }

    // 找到作物配置
    CropConfig? config;
    try {
      config = kCropConfigs.firstWhere((c) => c.cropId == cropId);
    } catch (e) {
      return FeedResult(success: false, message: '未知作物: $cropId');
    }

    // 消耗作物
    player.consumeItem(cropId, amount);

    // 喂食宠物（影响成长）
    pet.feed(config.type.name, amount);

    return FeedResult(
      success: true,
      message: '喂食成功！${pet.name} 吃了 $amount 个 ${config.name}',
      cropType: config.type.name,
      amount: amount,
    );
  }

  /// 购买种子
  static bool buySeed({
    required PlayerData player,
    required String cropId,
    required int quantity,
  }) {
    final config = kCropConfigs.firstWhere(
      (c) => c.cropId == cropId,
      orElse: () => throw Exception('Unknown crop: $cropId'),
    );

    // 种子价格 = 产量 * 10 金币
    final cost = config.yield * 10 * quantity;
    if (player.gold < cost) return false;

    player.gold -= cost;
    player.addItem('${cropId}_seed', quantity);
    return true;
  }

  /// 解锁新农田格子（消耗金币）
  static bool unlockPlot({
    required Farm farm,
    required PlayerData player,
  }) {
    if (player.gold < Farm.kUnlockCostPerPlot) return false;
    if (!farm.unlockNextPlot()) return false;
    player.gold -= Farm.kUnlockCostPerPlot;
    return true;
  }

  /// 获取农田状态摘要
  static FarmSummary getSummary(Farm farm) {
    farm.updateHarvestReady();
    return FarmSummary(
      totalPlots: farm.unlockedPlots,
      emptyPlots: farm.plots
          .sublist(0, farm.unlockedPlots)
          .where((p) => p.status == PlotStatus.EMPTY)
          .length,
      plantedPlots: farm.plots
          .sublist(0, farm.unlockedPlots)
          .where((p) => p.status == PlotStatus.PLANTED)
          .length,
      wateredPlots: farm.plots
          .sublist(0, farm.unlockedPlots)
          .where((p) => p.status == PlotStatus.WATERED)
          .length,
      readyToHarvest: farm.plots
          .sublist(0, farm.unlockedPlots)
          .where((p) => p.status == PlotStatus.READY_TO_HARVEST)
          .length,
    );
  }
}

/// 喂食结果
class FeedResult {
  final bool success;
  final String message;
  final String? cropType;
  final int amount;

  const FeedResult({
    required this.success,
    required this.message,
    this.cropType,
    this.amount = 0,
  });
}

/// 农田状态摘要
class FarmSummary {
  final int totalPlots;
  final int emptyPlots;
  final int plantedPlots;
  final int wateredPlots;
  final int readyToHarvest;

  const FarmSummary({
    required this.totalPlots,
    required this.emptyPlots,
    required this.plantedPlots,
    required this.wateredPlots,
    required this.readyToHarvest,
  });
}
