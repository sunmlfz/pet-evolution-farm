// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'battle.dart';

class BattleRoundAdapter extends TypeAdapter<BattleRound> {
  @override
  final int typeId = 6;

  @override
  BattleRound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BattleRound(
      roundNumber: fields[0] as int,
      actionTypeIndex: fields[1] as int,
      playerDamage: fields[2] as int,
      monsterDamage: fields[3] as int,
      playerHpLeft: fields[4] as int,
      monsterHpLeft: fields[5] as int,
      skillUsed: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BattleRound obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.roundNumber)
      ..writeByte(1)
      ..write(obj.actionTypeIndex)
      ..writeByte(2)
      ..write(obj.playerDamage)
      ..writeByte(3)
      ..write(obj.monsterDamage)
      ..writeByte(4)
      ..write(obj.playerHpLeft)
      ..writeByte(5)
      ..write(obj.monsterHpLeft)
      ..writeByte(6)
      ..write(obj.skillUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BattleRoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
