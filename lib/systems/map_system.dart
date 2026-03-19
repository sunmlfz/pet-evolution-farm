/// 地图区域配置
class MapArea {
  final String mapId;
  final String name;
  final String description;
  final String terrain; // forest / desert / mountain
  final int minLevel;   // 推荐最低等级
  final List<String> monsterIds;
  final List<String> resources; // 稀有资源
  final String? requiresMapId;  // 解锁前提（解锁顺序）
  final String spriteId;

  const MapArea({
    required this.mapId,
    required this.name,
    required this.description,
    required this.terrain,
    required this.minLevel,
    required this.monsterIds,
    required this.resources,
    this.requiresMapId,
    required this.spriteId,
  });
}

/// 静态地图配置
const List<MapArea> kMapAreas = [
  MapArea(
    mapId: 'forest_1',
    name: '新手森林',
    description: '宁静的森林，适合初出茅庐的宠物训练',
    terrain: 'forest',
    minLevel: 1,
    monsterIds: ['wild_rabbit', 'stone_crab'],
    resources: ['grass_herb', 'common_egg'],
    requiresMapId: null, // 默认解锁
    spriteId: 'map_forest_1',
  ),
  MapArea(
    mapId: 'desert_1',
    name: '炎热沙漠',
    description: '灼热的沙漠，危险的蝎子出没其中',
    terrain: 'desert',
    minLevel: 5,
    monsterIds: ['sand_scorpion'],
    resources: ['venom_sac', 'rare_egg'],
    requiresMapId: 'forest_1',
    spriteId: 'map_desert_1',
  ),
  MapArea(
    mapId: 'mountain_1',
    name: '险峻山岭',
    description: '山地中有强大的山岭熊守护着稀有资源',
    terrain: 'mountain',
    minLevel: 12,
    monsterIds: ['mountain_bear'],
    resources: ['bear_claw', 'special_egg'],
    requiresMapId: 'desert_1',
    spriteId: 'map_mountain_1',
  ),
];

/// 地图探索事件类型
enum ExploreEventType {
  BATTLE,        // 遭遇战斗
  FIND_RESOURCE, // 发现资源
  FIND_EGG,      // 发现宠物蛋
  HIDDEN_TASK,   // 隐藏任务
  NOTHING,       // 什么都没有
}

/// 探索事件
class ExploreEvent {
  final ExploreEventType type;
  final String? monsterId;
  final Map<String, int> resources;
  final String message;

  const ExploreEvent({
    required this.type,
    this.monsterId,
    this.resources = const {},
    required this.message,
  });
}

/// 地图系统 - 区域解锁、探索事件
class MapSystem {
  /// 检查是否可以解锁地图
  static bool canUnlock(String mapId, List<String> unlockedMapIds, int playerLevel) {
    final area = _getArea(mapId);
    if (area == null) return false;
    if (playerLevel < area.minLevel) return false;
    if (area.requiresMapId != null && !unlockedMapIds.contains(area.requiresMapId)) {
      return false;
    }
    return true;
  }

  /// 解锁地图区域
  static bool unlock(String mapId, List<String> unlockedMapIds, int playerLevel) {
    if (!canUnlock(mapId, unlockedMapIds, playerLevel)) return false;
    if (unlockedMapIds.contains(mapId)) return false;
    unlockedMapIds.add(mapId);
    return true;
  }

  /// 探索地图（随机事件）
  static ExploreEvent explore(String mapId, int petLevel) {
    final area = _getArea(mapId);
    if (area == null) {
      return const ExploreEvent(
        type: ExploreEventType.NOTHING,
        message: '未知地图区域',
      );
    }

    // 根据时间戳模拟随机（实际应使用 dart:math Random）
    final seed = DateTime.now().millisecondsSinceEpoch;
    final roll = seed % 100;

    if (roll < 50) {
      // 50% 概率遭遇战斗
      final monsterIdx = seed % area.monsterIds.length;
      return ExploreEvent(
        type: ExploreEventType.BATTLE,
        monsterId: area.monsterIds[monsterIdx.toInt()],
        message: '遭遇了野生怪物！',
      );
    } else if (roll < 70) {
      // 20% 发现资源
      if (area.resources.isNotEmpty) {
        final resIdx = seed % area.resources.length;
        final resourceId = area.resources[resIdx.toInt()];
        final count = (seed % 3 + 1).toInt();
        return ExploreEvent(
          type: ExploreEventType.FIND_RESOURCE,
          resources: {resourceId: count},
          message: '发现了 $count 个 $resourceId！',
        );
      }
    } else if (roll < 80) {
      // 10% 发现宠物蛋
      return ExploreEvent(
        type: ExploreEventType.FIND_EGG,
        resources: {'common_egg': 1},
        message: '发现了一枚宠物蛋！',
      );
    }

    return const ExploreEvent(
      type: ExploreEventType.NOTHING,
      message: '探索了一圈，什么都没发现...',
    );
  }

  /// 获取地图配置
  static MapArea? _getArea(String mapId) {
    try {
      return kMapAreas.firstWhere((a) => a.mapId == mapId);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有地图配置
  static List<MapArea> getAllAreas() => kMapAreas;

  /// 获取已解锁的地图
  static List<MapArea> getUnlockedAreas(List<String> unlockedMapIds) {
    return kMapAreas.where((a) => unlockedMapIds.contains(a.mapId)).toList();
  }
}
