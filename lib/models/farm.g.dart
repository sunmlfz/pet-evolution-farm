// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'farm.dart';

class FarmAdapter extends TypeAdapter<Farm> {
  @override
  final int typeId = 7;

  @override
  Farm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Farm(
      farmId: fields[0] as String,
      ownerId: fields[1] as String,
      plots: (fields[2] as List).cast<FarmPlot>(),
      unlockedPlots: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Farm obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.farmId)
      ..writeByte(1)
      ..write(obj.ownerId)
      ..writeByte(2)
      ..write(obj.plots)
      ..writeByte(3)
      ..write(obj.unlockedPlots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
