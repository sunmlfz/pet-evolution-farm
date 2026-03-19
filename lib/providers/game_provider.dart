import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/pet.dart';
import '../models/farm.dart';
import '../models/player.dart';
import '../models/battle.dart';
import '../systems/pet_system.dart';
import '../systems/farm_system.dart';
import '../systems/battle_system.dart';
import '../systems/map_system.dart';
import '../systems/evolution_system.dart';

const _uuid = Uuid();

// ============ PlayerData Provider ============

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerData>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerData> {
  late Box<PlayerData> _box;

  PlayerNotifier() : super(_createDefaultPlayer()) {
    _init();
  }

  static PlayerData _createDefaultPlayer() {
    return PlayerData(
      playerId: _uuid.v4(),
      nickname: '冒险者',
    );
  }

  Future<void> _init() async {
    _box = await Hive.openBox<PlayerData>('player');
    if (_box.isNotEmpty) {
      state = _box.values.first;
    } else {
      await _box.put('player', state);
    }
  }

  Future<void> _save() async {
    await _box.put('player', state);
  }

  /// 购买宠物蛋
  Future<Pet?> buyEgg(EggType eggType) async {
    final price = PetSystem.kEggPrices[eggType] ?? 100;
    if (!state.buyEgg(price)) return null;
    final egg = PetSystem.createEgg(eggType);
    state.petIds.add(egg.petId);
    await _save();
    return egg;
  }

  /// 更新玩家数据
  Future<void> update(PlayerData player) async {
    state = player;
    await _save();
  }
}

// ============ Farm Provider ============

final farmProvider = StateNotifierProvider<FarmNotifier, Farm>((ref) {
  return FarmNotifier();
});

class FarmNotifier extends StateNotifier<Farm> {
  late Box<Farm> _box;

  FarmNotifier()
      : super(Farm(
          farmId: _uuid.v4(),
          ownerId: 'default',
        )) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Farm>('farm');
    if (_box.isNotEmpty) {
      state = _box.values.first;
    } else {
      await _box.put('farm', state);
    }
  }

  Future<void> _save() async {
    await _box.put('farm', state);
  }

  /// 种植
  Future<bool> plant(
      int plotIndex, String cropId, PlayerData player, WidgetRef ref) async {
    final success = FarmSystem.plant(
      farm: state,
      player: player,
      plotIndex: plotIndex,
      cropId: cropId,
    );
    if (success) {
      await _save();
      await ref.read(playerProvider.notifier).update(player);
    }
    return success;
  }

  /// 浇水
  Future<bool> water(int plotIndex) async {
    final success = FarmSystem.water(farm: state, plotIndex: plotIndex);
    if (success) await _save();
    return success;
  }

  /// 收割
  Future<Map<String, int>> harvest(
      int plotIndex, PlayerData player, WidgetRef ref) async {
    final result = FarmSystem.harvest(
      farm: state,
      player: player,
      plotIndex: plotIndex,
    );
    if (result.isNotEmpty) {
      await _save();
      await ref.read(playerProvider.notifier).update(player);
    }
    return result;
  }

  /// 收割全部
  Future<Map<String, int>> harvestAll(PlayerData player, WidgetRef ref) async {
    final result = FarmSystem.harvestAll(farm: state, player: player);
    if (result.isNotEmpty) {
      await _save();
      await ref.read(playerProvider.notifier).update(player);
    }
    return result;
  }
}

// ============ Pets Provider ============

final petsProvider = StateNotifierProvider<PetsNotifier, List<Pet>>((ref) {
  return PetsNotifier();
});

class PetsNotifier extends StateNotifier<List<Pet>> {
  late Box<Pet> _box;

  PetsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Pet>('pets');
    state = _box.values.toList();
  }

  Future<void> _save(Pet pet) async {
    await _box.put(pet.petId, pet);
    state = _box.values.toList();
  }

  /// 添加宠物
  Future<void> addPet(Pet pet) async {
    await _save(pet);
  }

  /// 孵化宠物蛋
  Future<Pet?> hatch(String petId) async {
    final pet = _box.get(petId);
    if (pet == null) return null;
    final hatched = PetSystem.hatch(pet);
    if (hatched != null) {
      await _save(hatched);
      return hatched;
    }
    return null;
  }

  /// 喂食
  Future<FeedResult> feed(
      String petId, String cropId, int amount, PlayerData player, WidgetRef ref) async {
    final pet = _box.get(petId);
    if (pet == null) {
      return const FeedResult(success: false, message: '宠物不存在');
    }
    final result = FarmSystem.feedPet(
      player: player,
      pet: pet,
      cropId: cropId,
      amount: amount,
    );
    if (result.success) {
      await _save(pet);
      await ref.read(playerProvider.notifier).update(player);
    }
    return result;
  }

  /// 进化
  Future<EvolutionResult?> evolve(String petId) async {
    final pet = _box.get(petId);
    if (pet == null) return null;
    final result = EvolutionSystem.evolve(pet);
    if (result.success) await _save(pet);
    return result;
  }
}

// ============ Battle Provider ============

final battleProvider =
    StateNotifierProvider<BattleNotifier, BattleState>((ref) {
  return BattleNotifier(ref);
});

class BattleState {
  final bool inBattle;
  final BattleSession? session;
  final BattleSettlement? lastSettlement;

  const BattleState({
    this.inBattle = false,
    this.session,
    this.lastSettlement,
  });
}

class BattleNotifier extends StateNotifier<BattleState> {
  final Ref _ref;

  BattleNotifier(this._ref) : super(const BattleState());

  /// 开始战斗
  void startBattle(Pet pet, String monsterId, String mapId) {
    final session = BattleSystem.startBattle(
      playerPet: pet,
      monsterId: monsterId,
      mapId: mapId,
    );
    session.execute();
    state = BattleState(inBattle: true, session: session);
  }

  /// 结算战斗
  Future<BattleSettlement> settle() async {
    final session = state.session;
    if (session == null) throw Exception('No active battle session');

    final player = _ref.read(playerProvider);
    final settlement = BattleSystem.settle(
      result: session.result,
      playerPet: session.playerPet,
      player: player,
    );

    // 保存宠物状态
    await _ref.read(petsProvider.notifier).addPet(session.playerPet);
    // 保存玩家状态
    await _ref.read(playerProvider.notifier).update(player);

    state = BattleState(inBattle: false, lastSettlement: settlement);
    return settlement;
  }
}
