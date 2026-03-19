import 'package:hive/hive.dart';

part 'crop.g.dart';

/// 作物类型 - 对应不同成长方向
enum CropType {
  ATTACK,  // 攻击型：火辣椒、铁荆棘
  DEFENSE, // 防御型：金盾菇、坚壁草
  SKILL,   // 技能型：灵芝、星光花
}

/// 农田格状态
enum PlotStatus {
  EMPTY,             // 空地
  PLANTED,           // 已种植（未浇水）
  WATERED,           // 已浇水
  READY_TO_HARVEST,  // 可收割
}

/// 作物配置（静态配置）
class CropConfig {
  final String cropId;
  final String name;
  final CropType type;
  final int growTimeMs;   // 生长时间（毫秒）
  final int yield;        // 产量
  final String description;
  final String spriteId;

  const CropConfig({
    required this.cropId,
    required this.name,
    required this.type,
    required this.growTimeMs,
    required this.yield,
    required this.description,
    required this.spriteId,
  });
}

/// 静态作物配置表
const List<CropConfig> kCropConfigs = [
  CropConfig(
    cropId: 'fire_pepper',
    name: '火辣椒',
    type: CropType.ATTACK,
    growTimeMs: 60 * 60 * 1000, // 1小时
    yield: 3,
    description: '提升宠物攻击属性',
    spriteId: 'crop_fire_pepper',
  ),
  CropConfig(
    cropId: 'iron_thorn',
    name: '铁荆棘',
    type: CropType.ATTACK,
    growTimeMs: 2 * 60 * 60 * 1000, // 2小时
    yield: 5,
    description: '大幅提升宠物力量',
    spriteId: 'crop_iron_thorn',
  ),
  CropConfig(
    cropId: 'gold_shield_mushroom',
    name: '金盾菇',
    type: CropType.DEFENSE,
    growTimeMs: 90 * 60 * 1000, // 1.5小时
    yield: 3,
    description: '提升宠物防御属性',
    spriteId: 'crop_gold_shield',
  ),
  CropConfig(
    cropId: 'hard_wall_grass',
    name: '坚壁草',
    type: CropType.DEFENSE,
    growTimeMs: 3 * 60 * 60 * 1000, // 3小时
    yield: 6,
    description: '大幅提升宠物耐力',
    spriteId: 'crop_hard_wall',
  ),
  CropConfig(
    cropId: 'lingzhi',
    name: '灵芝',
    type: CropType.SKILL,
    growTimeMs: 4 * 60 * 60 * 1000, // 4小时
    yield: 2,
    description: '解锁宠物特殊技能',
    spriteId: 'crop_lingzhi',
  ),
  CropConfig(
    cropId: 'starlight_flower',
    name: '星光花',
    type: CropType.SKILL,
    growTimeMs: 6 * 60 * 60 * 1000, // 6小时
    yield: 4,
    description: '大幅提升技能熟练度',
    spriteId: 'crop_starlight',
  ),
];

/// 单个农田格数据
@HiveType(typeId: 4)
class FarmPlot extends HiveObject {
  @HiveField(0)
  int plotIndex; // 0-15（4×4农田）

  @HiveField(1)
  int statusIndex; // PlotStatus 索引

  @HiveField(2)
  String? cropId; // 当前种植的作物ID

  @HiveField(3)
  int plantTimeMs; // 种植时间戳（毫秒）

  @HiveField(4)
  int waterTimeMs; // 最后浇水时间戳

  FarmPlot({
    required this.plotIndex,
    this.statusIndex = 0,
    this.cropId,
    this.plantTimeMs = 0,
    this.waterTimeMs = 0,
  });

  PlotStatus get status => PlotStatus.values[statusIndex];

  /// 获取当前作物配置
  CropConfig? get cropConfig {
    if (cropId == null) return null;
    try {
      return kCropConfigs.firstWhere((c) => c.cropId == cropId);
    } catch (e) {
      return null;
    }
  }

  /// 检查是否可以收割
  bool checkHarvestReady() {
    if (status != PlotStatus.WATERED) return false;
    final config = cropConfig;
    if (config == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    final growTime = config.growTimeMs;
    // 浇水后生长时间减半
    return now - waterTimeMs >= growTime ~/ 2;
  }

  /// 种植作物
  void plant(String cropId) {
    this.cropId = cropId;
    statusIndex = PlotStatus.PLANTED.index;
    plantTimeMs = DateTime.now().millisecondsSinceEpoch;
    waterTimeMs = 0;
  }

  /// 浇水
  void water() {
    if (status != PlotStatus.PLANTED) return;
    statusIndex = PlotStatus.WATERED.index;
    waterTimeMs = DateTime.now().millisecondsSinceEpoch;
  }

  /// 收割（返回作物产量，若不可收割返回0）
  int harvest() {
    if (!checkHarvestReady()) return 0;
    final config = cropConfig;
    if (config == null) return 0;
    final yield = config.yield;
    // 重置农田
    cropId = null;
    statusIndex = PlotStatus.EMPTY.index;
    plantTimeMs = 0;
    waterTimeMs = 0;
    return yield;
  }
}
