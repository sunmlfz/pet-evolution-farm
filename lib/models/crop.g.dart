// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'crop.dart';

class FarmPlotAdapter extends TypeAdapter<FarmPlot> {
  @override
  final int typeId = 4;

  @override
  FarmPlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmPlot(
      plotIndex: fields[0] as int,
      statusIndex: fields[1] as int,
      cropId: fields[2] as String?,
      plantTimeMs: fields[3] as int,
      waterTimeMs: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FarmPlot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.plotIndex)
      ..writeByte(1)
      ..write(obj.statusIndex)
      ..writeByte(2)
      ..write(obj.cropId)
      ..writeByte(3)
      ..write(obj.plantTimeMs)
      ..writeByte(4)
      ..write(obj.waterTimeMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmPlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
