/// 图鉴系统 - 记录玩家的探索与收集进度
/// 注意：此类使用 JSON 序列化存储，不依赖 Hive build_runner 生成
class PlayerDex {
  /// 宠物图鉴：species -> 收集数量
  Map<String, int> collectedPets;

  /// 怪物图鉴：monsterId -> kill count（遭遇即解锁，击败计 kills）
  Map<String, int> defeatedMonsters;

  /// 作物图鉴：cropId -> 总收割数量
  Map<String, int> harvestedCrops;

  /// 地图图鉴：mapId -> 探索次数
  Map<String, int> exploredMaps;

  /// 宠物蛋图鉴：EggType -> 购买次数
  Map<String, int> boughtEggs;

  /// 已遭遇（非必须击败）的怪物集合
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

  factory PlayerDex.fromJson(Map<String, dynamic> json) => PlayerDex(
        collectedPets: Map<String, int>.from(json['collectedPets'] ?? {}),
        defeatedMonsters: Map<String, int>.from(json['defeatedMonsters'] ?? {}),
        harvestedCrops: Map<String, int>.from(json['harvestedCrops'] ?? {}),
        exploredMaps: Map<String, int>.from(json['exploredMaps'] ?? {}),
        boughtEggs: Map<String, int>.from(json['boughtEggs'] ?? {}),
        encounteredMonsters: List<String>.from(json['encounteredMonsters'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'collectedPets': collectedPets,
        'defeatedMonsters': defeatedMonsters,
        'harvestedCrops': harvestedCrops,
        'exploredMaps': exploredMaps,
        'boughtEggs': boughtEggs,
        'encounteredMonsters': encounteredMonsters,
      };

  void recordPetHatch(String species) =>
      collectedPets[species] = (collectedPets[species] ?? 0) + 1;

  void recordMonsterEncounter(String monsterId) {
    if (!encounteredMonsters.contains(monsterId)) encounteredMonsters.add(monsterId);
  }

  void recordMonsterKill(String monsterId) {
    recordMonsterEncounter(monsterId);
    defeatedMonsters[monsterId] = (defeatedMonsters[monsterId] ?? 0) + 1;
  }

  void recordHarvest(String cropId, int amount) =>
      harvestedCrops[cropId] = (harvestedCrops[cropId] ?? 0) + amount;

  void recordExplore(String mapId) =>
      exploredMaps[mapId] = (exploredMaps[mapId] ?? 0) + 1;

  void recordEggBought(String eggType) =>
      boughtEggs[eggType] = (boughtEggs[eggType] ?? 0) + 1;

  int get totalPetSpecies => collectedPets.keys.length;
  int get totalMonstersEncountered => encounteredMonsters.length;
  int get totalKills => defeatedMonsters.values.fold(0, (a, b) => a + b);
  int get totalCropTypes => harvestedCrops.keys.length;
  int get totalMapsExplored => exploredMaps.keys.length;
  int getMonsterKills(String monsterId) => defeatedMonsters[monsterId] ?? 0;
  bool hasEncountered(String monsterId) => encounteredMonsters.contains(monsterId);
}
