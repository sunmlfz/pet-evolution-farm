// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'player.dart';

class PlayerDataAdapter extends TypeAdapter<PlayerData> {
  @override
  final int typeId = 5;

  @override
  PlayerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerData(
      playerId: fields[0] as String,
      nickname: fields[1] as String,
      gold: fields[2] as int,
      gems: fields[3] as int,
      level: fields[4] as int,
      experience: fields[5] as int,
      petIds: (fields[6] as List).cast<String>(),
      activePetId: fields[7] as String?,
      unlockedMapIds: (fields[8] as List).cast<String>(),
      inventory: (fields[9] as Map).cast<String, int>(),
      totalBattles: fields[10] as int,
      totalWins: fields[11] as int,
      createdAtMs: fields[12] as int?,
      lastLoginMs: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerData obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.gold)
      ..writeByte(3)
      ..write(obj.gems)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.experience)
      ..writeByte(6)
      ..write(obj.petIds)
      ..writeByte(7)
      ..write(obj.activePetId)
      ..writeByte(8)
      ..write(obj.unlockedMapIds)
      ..writeByte(9)
      ..write(obj.inventory)
      ..writeByte(10)
      ..write(obj.totalBattles)
      ..writeByte(11)
      ..write(obj.totalWins)
      ..writeByte(12)
      ..write(obj.createdAtMs)
      ..writeByte(13)
      ..write(obj.lastLoginMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
