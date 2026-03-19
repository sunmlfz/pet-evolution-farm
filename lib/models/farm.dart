import 'package:hive/hive.dart';
import 'crop.dart';

part 'farm.g.dart';

/// 农田数据（4×4 = 16个农田格）
@HiveType(typeId: 7)
class Farm extends HiveObject {
  static const int kRows = 4;
  static const int kCols = 4;
  static const int kTotalPlots = kRows * kCols;

  @HiveField(0)
  String farmId;

  @HiveField(1)
  String ownerId; // 玩家 playerId

  @HiveField(2)
  List<FarmPlot> plots;

  @HiveField(3)
  int unlockedPlots; // 已解锁格子数（初始解锁4格，后续扩展）

  Farm({
    required this.farmId,
    required this.ownerId,
    List<FarmPlot>? plots,
    this.unlockedPlots = 4,
  }) : plots = plots ??
            List.generate(
              kTotalPlots,
              (i) => FarmPlot(plotIndex: i),
            );

  /// 获取指定格子
  FarmPlot plotAt(int row, int col) => plots[row * kCols + col];

  /// 获取已解锁的可用格子列表
  List<FarmPlot> get availablePlots =>
      plots.sublist(0, unlockedPlots);

  /// 统计各状态格子数量
  int countByStatus(PlotStatus status) =>
      plots.where((p) => p.status == status).length;

  /// 检查并更新所有可收割状态
  void updateHarvestReady() {
    for (final plot in plots) {
      if (plot.status == PlotStatus.WATERED && plot.checkHarvestReady()) {
        plot.statusIndex = PlotStatus.READY_TO_HARVEST.index;
      }
    }
  }

  /// 种植
  bool plant(int plotIndex, String cropId) {
    if (plotIndex >= unlockedPlots) return false;
    final plot = plots[plotIndex];
    if (plot.status != PlotStatus.EMPTY) return false;
    plot.plant(cropId);
    return true;
  }

  /// 浇水
  bool water(int plotIndex) {
    if (plotIndex >= unlockedPlots) return false;
    final plot = plots[plotIndex];
    if (plot.status != PlotStatus.PLANTED) return false;
    plot.water();
    return true;
  }

  /// 收割（返回 {cropId: yield}，若无可收割则返回空 map）
  Map<String, int> harvest(int plotIndex) {
    if (plotIndex >= unlockedPlots) return {};
    updateHarvestReady();
    final plot = plots[plotIndex];
    if (plot.status != PlotStatus.READY_TO_HARVEST) return {};
    final cropId = plot.cropId;
    if (cropId == null) return {};
    final yield = plot.harvest();
    if (yield <= 0) return {};
    return {cropId: yield};
  }

  /// 收割全部可收割的格子
  Map<String, int> harvestAll() {
    updateHarvestReady();
    final result = <String, int>{};
    for (int i = 0; i < unlockedPlots; i++) {
      final harvested = harvest(i);
      harvested.forEach((cropId, count) {
        result[cropId] = (result[cropId] ?? 0) + count;
      });
    }
    return result;
  }

  /// 解锁新格子（消耗金币）
  static const int kUnlockCostPerPlot = 200;
  bool unlockNextPlot() {
    if (unlockedPlots >= kTotalPlots) return false;
    unlockedPlots++;
    return true;
  }
}
