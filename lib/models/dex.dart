import 'package:hive/hive.dart';

part 'dex.g.dart';

/// 图鉴系统 - 记录玩家的探索与收集进度
@HiveType(typeId: 8)
class PlayerDex extends HiveObject {
  /// 宠物图鉴：species -> 收集数量
  @HiveField(0)
  Map<String, int> collectedPets;

  /// 怪物图鉴：monsterId -> {kills: int, firstMet: timestamp}
  @HiveField(1)
  Map<String, int> defeatedMonsters; // monsterId -> kill count

  /// 作物图鉴：cropId -> 总收割数量
  @HiveField(2)
  Map<String, int> harvestedCrops;

  /// 地图图鉴：mapId -> 探索次数
  @HiveField(3)
  Map<String, int> exploredMaps;

  /// 宠物蛋图鉴：EggType -> 购买次数
  @HiveField(4)
  Map<String, int> boughtEggs;

  /// 已遭遇（非必须击败）的怪物集合
  @HiveField(5)
  List<String> encounteredMonsters;

  PlayerDex({
    Map<String, int>? collectedPets,
    Map<String, int>? defeatedMonsters,
    Map<String, int>? harvestedCrops,
    Map<String, int>? exploredMaps,
    Map<String, int>? boughtEggs,
    List<String>? encounteredMonsters,
  })  : collectedPets = collectedPets ?? {},
        defeatedMonsters = defeatedMonsters ?? {},
        harvestedCrops = harvestedCrops ?? {},
        exploredMaps = exploredMaps ?? {},
        boughtEggs = boughtEggs ?? {},
        encounteredMonsters = encounteredMonsters ?? [];

  /// 记录孵化了一只新宠物
  void recordPetHatch(String species) {
    collectedPets[species] = (collectedPets[species] ?? 0) + 1;
  }

  /// 记录遭遇怪物（解锁图鉴条目）
  void recordMonsterEncounter(String monsterId) {
    if (!encounteredMonsters.contains(monsterId)) {
      encounteredMonsters.add(monsterId);
    }
  }

  /// 记录击败怪物
  void recordMonsterKill(String monsterId) {
    recordMonsterEncounter(monsterId);
    defeatedMonsters[monsterId] = (defeatedMonsters[monsterId] ?? 0) + 1;
  }

  /// 记录收割作物
  void recordHarvest(String cropId, int amount) {
    harvestedCrops[cropId] = (harvestedCrops[cropId] ?? 0) + amount;
  }

  /// 记录探索地图
  void recordExplore(String mapId) {
    exploredMaps[mapId] = (exploredMaps[mapId] ?? 0) + 1;
  }

  /// 记录购买宠物蛋
  void recordEggBought(String eggType) {
    boughtEggs[eggType] = (boughtEggs[eggType] ?? 0) + 1;
  }

  // ===== 统计属性 =====

  /// 已收集宠物物种数
  int get totalPetSpecies => collectedPets.keys.length;

  /// 已遭遇怪物数
  int get totalMonstersEncountered => encounteredMonsters.length;

  /// 已击败怪物总数（所有怪物类型击杀次数之和）
  int get totalKills => defeatedMonsters.values.fold(0, (a, b) => a + b);

  /// 已解锁作物种类数
  int get totalCropTypes => harvestedCrops.keys.length;

  /// 已探索地图数
  int get totalMapsExplored => exploredMaps.keys.length;

  /// 已购买蛋类型数
  int get totalEggTypes => boughtEggs.keys.length;

  /// 获取指定怪物击杀数
  int getMonsterKills(String monsterId) => defeatedMonsters[monsterId] ?? 0;

  /// 是否已遭遇指定怪物
  bool hasEncountered(String monsterId) => encounteredMonsters.contains(monsterId);
}
