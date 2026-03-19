# 🐾 宠物进化田园

养成 + 收集 + 战斗 + 农场经营类 Flutter 游戏

## 游戏简介

购买宠物蛋孵化宠物，用农田种植的作物喂养宠物影响成长方向，带宠物探索地图战斗获得经验，最终进化为强大的形态！

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter | 跨平台 UI 框架 |
| Flame | 游戏引擎（动画、战斗效果） |
| Riverpod | 状态管理 |
| Hive | 本地持久化存储 |
| uuid | 唯一 ID 生成 |

## 核心系统

### 🥚 宠物系统（PetSystem）
- 三类宠物蛋：普通 / 稀有 / 特殊
- 孵化随机物种和初始属性
- 11种宠物物种，各有独特技能
- 战斗经验 + 喂养影响成长

### 🌱 农田系统（FarmSystem）
- 4×4 可扩展农田（初始解锁4格）
- 三类作物：攻击型 / 防御型 / 技能型
- 种植 → 浇水 → 收割完整流程
- 作物喂食影响宠物进化方向

### ⚔️ 战斗系统（BattleSystem）
- 回合制战斗引擎
- 技能战斗提升技能熟练度
- 胜利获得经验、金币、物品掉落

### 🌟 进化系统（EvolutionSystem）
- 4个进化阶段：NONE → FIRST → SECOND → FINAL
- 特殊稀有进化：RARE（特殊蛋 + 特定条件触发）
- 喂食主导方向决定进化属性加成

### 🗺️ 地图系统（MapSystem）
- 3大地形区域：新手森林 / 炎热沙漠 / 险峻山岭
- 随机探索事件：战斗 / 资源 / 宠物蛋 / 无事发生
- 等级限制 + 顺序解锁

## 项目结构

```
lib/
├── main.dart                    # 入口文件
├── models/
│   ├── pet.dart                 # 宠物模型（Pet / PetStats / PetSkill）
│   ├── crop.dart                # 作物模型（FarmPlot / CropConfig）
│   ├── farm.dart                # 农田模型（Farm）
│   ├── battle.dart              # 战斗模型（BattleEngine / MonsterConfig）
│   └── player.dart              # 玩家模型（PlayerData）
├── systems/
│   ├── pet_system.dart          # 宠物孵化、技能管理
│   ├── farm_system.dart         # 种植、收割、喂食
│   ├── battle_system.dart       # 战斗调度、奖励结算
│   ├── evolution_system.dart    # 进化条件判断、执行
│   └── map_system.dart          # 地图区域、探索事件
├── providers/
│   └── game_provider.dart       # Riverpod 状态管理
└── screens/
    ├── home_screen.dart         # 主界面（底部导航）
    ├── pet_screen.dart          # 宠物详情页
    ├── farm_screen.dart         # 农田操作页
    ├── battle_screen.dart       # 战斗界面
    └── map_screen.dart          # 地图探索页
```

## 数据模型关键字段

### PlayerData
- `playerId`: 玩家唯一ID（String，UUID格式）
- `gold` / `gems`: 游戏货币
- `activePetId`: 当前出战宠物（MVP：单宠物出战）
- `inventory`: 背包 Map<String, int>

### Pet
- `eggType`: `EggType.COMMON / RARE / SPECIAL`
- `evolutionStage`: `EvolutionStage.NONE / FIRST / SECOND / FINAL / RARE`
- `feedingHistory`: Map<"ATTACK"|"DEFENSE"|"SKILL", int>
- `dominantFeedType`: 决定进化方向的主导喂食类型

## 运行方式

```bash
# 安装依赖
flutter pub get

# 生成 Hive 适配器
dart run build_runner build

# 运行
flutter run
```

## MVP 范围

✅ 已实现：
- 宠物蛋购买与孵化
- 农田种植 / 浇水 / 收割
- 宠物喂食（影响成长）
- 回合制战斗
- 地图探索与怪物遭遇
- 进化系统（含稀有进化）
- 本地数据持久化（Hive）

❌ 不在 MVP（后期扩展）：
- 联机/后端服务
- PVP/竞技场
- 图鉴/成就系统
- 多宠物同时出战

---

**开发：机器人2号 🦞**  
**架构：机器人4号（菜鸟开发者）**  
**产品：机器人1号（opencalw-bot1）**
