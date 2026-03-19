import 'package:hive/hive.dart';

part 'player.g.dart';

/// 玩家数据模型
@HiveType(typeId: 5)
class PlayerData extends HiveObject {
  @HiveField(0)
  String playerId; // 玩家唯一ID（修正：原架构文档误用 odId）

  @HiveField(1)
  String nickname;

  @HiveField(2)
  int gold; // 金币

  @HiveField(3)
  int gems; // 宝石（高级货币）

  @HiveField(4)
  int level; // 玩家等级

  @HiveField(5)
  int experience;

  @HiveField(6)
  List<String> petIds; // 拥有的宠物ID列表

  @HiveField(7)
  String? activePetId; // 当前上阵宠物ID（MVP：单宠物出战）

  @HiveField(8)
  List<String> unlockedMapIds; // 已解锁地图区域

  @HiveField(9)
  Map<String, int> inventory; // 背包 {itemId: count}，含作物

  @HiveField(10)
  int totalBattles; // 累计战斗场次

  @HiveField(11)
  int totalWins;    // 累计胜利场次

  @HiveField(12)
  int createdAtMs; // 创建时间戳

  @HiveField(13)
  int lastLoginMs; // 最后登录时间戳

  PlayerData({
    required this.playerId,
    required this.nickname,
    this.gold = 500,
    this.gems = 10,
    this.level = 1,
    this.experience = 0,
    List<String>? petIds,
    this.activePetId,
    List<String>? unlockedMapIds,
    Map<String, int>? inventory,
    this.totalBattles = 0,
    this.totalWins = 0,
    int? createdAtMs,
    int? lastLoginMs,
  })  : petIds = petIds ?? [],
        unlockedMapIds = unlockedMapIds ?? ['forest_1'],
        inventory = inventory ?? {},
        createdAtMs = createdAtMs ?? DateTime.now().millisecondsSinceEpoch,
        lastLoginMs = lastLoginMs ?? DateTime.now().millisecondsSinceEpoch;

  /// 胜率
  double get winRate => totalBattles > 0 ? totalWins / totalBattles : 0.0;

  /// 升级所需经验
  int get expToNextLevel => level * 200 + level * level * 50;

  /// 添加物品到背包
  void addItem(String itemId, int count) {
    inventory[itemId] = (inventory[itemId] ?? 0) + count;
  }

  /// 消耗物品
  bool consumeItem(String itemId, int count) {
    final current = inventory[itemId] ?? 0;
    if (current < count) return false;
    inventory[itemId] = current - count;
    if (inventory[itemId] == 0) inventory.remove(itemId);
    return true;
  }

  /// 获取物品数量
  int getItemCount(String itemId) => inventory[itemId] ?? 0;

  /// 购买宠物蛋（消耗金币）
  bool buyEgg(int cost) {
    if (gold < cost) return false;
    gold -= cost;
    return true;
  }
}
