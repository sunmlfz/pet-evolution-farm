import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crop.dart';
import '../providers/game_provider.dart';
import '../systems/farm_system.dart';

/// 农田详细操作页
class FarmScreen extends ConsumerWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);
    final player = ref.watch(playerProvider);
    final summary = FarmSystem.getSummary(farm);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 我的农田'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.agriculture),
            tooltip: '一键收割',
            onPressed: () async {
              final result = await ref
                  .read(farmProvider.notifier)
                  .harvestAll(player, ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.isEmpty
                        ? '没有可收割的作物'
                        : '收割成功！获得 ${result.entries.map((e) => '${e.value}×${e.key}').join('、')}'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 农田状态概览
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryChip('空地', '${summary.emptyPlots}', '🟫'),
                _SummaryChip('已种', '${summary.plantedPlots}', '🌱'),
                _SummaryChip('已浇水', '${summary.wateredPlots}', '💧'),
                _SummaryChip('可收割', '${summary.readyToHarvest}', '🌾'),
              ],
            ),
          ),
          // 农田网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 16,
              itemBuilder: (ctx, i) {
                final isUnlocked = i < farm.unlockedPlots;
                final plot = farm.plots[i];
                return GestureDetector(
                  onTap: isUnlocked
                      ? () => _showPlotMenu(context, ref, i, plot.status)
                      : null,
                  child: _PlotTile(
                    status: isUnlocked ? plot.status : null,
                    cropId: plot.cropId,
                  ),
                );
              },
            ),
          ),
          // 种子商店
          const _SeedShop(),
        ],
      ),
    );
  }

  void _showPlotMenu(
      BuildContext context, WidgetRef ref, int plotIndex, PlotStatus status) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _PlotActionSheet(plotIndex: plotIndex, status: status),
    );
  }
}

/// 农田格组件
class _PlotTile extends StatelessWidget {
  final PlotStatus? status;
  final String? cropId;
  const _PlotTile({this.status, this.cropId});

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('🔒', style: TextStyle(fontSize: 20))),
      );
    }

    String emoji;
    Color color;
    switch (status!) {
      case PlotStatus.EMPTY:
        emoji = '🟫';
        color = Colors.brown.shade100;
        break;
      case PlotStatus.PLANTED:
        emoji = '🌱';
        color = Colors.green.shade100;
        break;
      case PlotStatus.WATERED:
        emoji = '💧';
        color = Colors.blue.shade100;
        break;
      case PlotStatus.READY_TO_HARVEST:
        emoji = '🌾';
        color = Colors.yellow.shade100;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}

/// 农田格操作菜单
class _PlotActionSheet extends ConsumerWidget {
  final int plotIndex;
  final PlotStatus status;
  const _PlotActionSheet({required this.plotIndex, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('选择操作', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (status == PlotStatus.EMPTY)
            ListTile(
              leading: const Text('🌱', style: TextStyle(fontSize: 24)),
              title: const Text('种植作物'),
              onTap: () {
                Navigator.pop(context);
                _showCropPicker(context, ref);
              },
            ),
          if (status == PlotStatus.PLANTED)
            ListTile(
              leading: const Text('💧', style: TextStyle(fontSize: 24)),
              title: const Text('浇水'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(farmProvider.notifier).water(plotIndex);
              },
            ),
          if (status == PlotStatus.READY_TO_HARVEST)
            ListTile(
              leading: const Text('🌾', style: TextStyle(fontSize: 24)),
              title: const Text('收割'),
              onTap: () async {
                Navigator.pop(context);
                final player = ref.read(playerProvider);
                await ref.read(farmProvider.notifier).harvest(plotIndex, player, ref);
              },
            ),
        ],
      ),
    );
  }

  void _showCropPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('选择作物'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: kCropConfigs
              .map((crop) => ListTile(
                    title: Text(crop.name),
                    subtitle: Text(crop.description),
                    onTap: () async {
                      Navigator.pop(context);
                      final player = ref.read(playerProvider);
                      final success = await ref
                          .read(farmProvider.notifier)
                          .plant(plotIndex, crop.cropId, player, ref);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('种植失败：缺少 ${crop.name} 种子')),
                        );
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// 种子商店
class _SeedShop extends ConsumerWidget {
  const _SeedShop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(top: BorderSide(color: Colors.green.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛒 种子商店',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kCropConfigs
                  .map((crop) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () async {
                            final player = ref.read(playerProvider);
                            final ok = FarmSystem.buySeed(
                              player: player,
                              cropId: crop.cropId,
                              quantity: 3,
                            );
                            await ref
                                .read(playerProvider.notifier)
                                .update(player);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? '购买 ${crop.name} 种子 ×3 成功'
                                      : '金币不足'),
                                ),
                              );
                            }
                          },
                          child: Text(
                              '${crop.name}\n🪙${crop.yield * 10 * 3}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String count;
  final String emoji;
  const _SummaryChip(this.label, this.count, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
