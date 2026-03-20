import '../models/pet.dart';
import '../models/battle.dart';
import '../models/player.dart';
import 'evolution_system.dart';

/// 战斗系统 - 地图遭遇、回合制战斗、奖励结算
class BattleSystem {
  /// 发起战斗
  static BattleSession startBattle({
    required Pet playerPet,
    required String monsterId,
    required String mapId,
  }) {
    final monster = kMonsterConfigs.firstWhere(
      (m) => m.monsterId == monsterId,
      orElse: () => kMonsterConfigs.first,
    );

    return BattleSession(
      playerPet: playerPet,
      monster: monster,
      mapId: mapId,
    );
  }

  /// 结算战斗结果，更新玩家和宠物数据
  static BattleSettlement settle({
    required BattleResult result,
    required Pet playerPet,
    required PlayerData player,
  }) {
    // 宠物获得经验
    playerPet.gainBattleExp(result.expGained, result.playerWon);

    // 玩家获得金币
    player.gold += result.goldGained;
    player.totalBattles++;
    if (result.playerWon) player.totalWins++;

    // 物品进入背包
    for (final item in result.itemsDropped) {
      player.addItem(item, 1);
    }

    // 宠物升级（可能多次）
    final levelUps = <int>[];
    while (playerPet.canLevelUp) {
      // ignore: unused_local_variable
      final oldLevel = playerPet.level;
      playerPet.levelUp();
      levelUps.add(playerPet.level);
    }

    // 检查是否可以进化
    final canEvolve = EvolutionSystem.canEvolve(playerPet);
    EvolutionResult? evolutionResult;
    if (canEvolve) {
      evolutionResult = EvolutionSystem.evolve(playerPet);
    }

    return BattleSettlement(
      result: result,
      levelUps: levelUps,
      evolutionResult: evolutionResult,
    );
  }

  /// 根据地图获取可遭遇怪物列表
  static List<MonsterConfig> getMonstersInMap(String mapId) {
    return kMonsterConfigs.where((m) => m.mapId == mapId).toList();
  }

  /// 随机选择一只怪物（地图探索时遭遇）
  static MonsterConfig? randomEncounter(String mapId) {
    final monsters = getMonstersInMap(mapId);
    if (monsters.isEmpty) return null;
    final idx = DateTime.now().millisecondsSinceEpoch % monsters.length;
    return monsters[idx.toInt()];
  }
}

/// 战斗会话（进行中）
class BattleSession {
  final Pet playerPet;
  final MonsterConfig monster;
  final String mapId;
  late BattleResult result;

  BattleSession({
    required this.playerPet,
    required this.monster,
    required this.mapId,
  });

  /// 执行战斗
  void execute() {
    result = BattleEngine.fight(
      playerPet: playerPet,
      monster: monster,
    );
  }
}

/// 战斗结算结果
class BattleSettlement {
  final BattleResult result;
  final List<int> levelUps;
  final EvolutionResult? evolutionResult;

  const BattleSettlement({
    required this.result,
    required this.levelUps,
    this.evolutionResult,
  });

  bool get hasLevelUp => levelUps.isNotEmpty;
  bool get hasEvolution => evolutionResult?.success == true;
}
