// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetSkillAdapter extends TypeAdapter<PetSkill> {
  @override
  final int typeId = 1;

  @override
  PetSkill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetSkill(
      skillId: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      proficiency: fields[3] as int,
      damage: fields[4] as int,
      type: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PetSkill obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.skillId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.proficiency)
      ..writeByte(4)
      ..write(obj.damage)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetSkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetStatsAdapter extends TypeAdapter<PetStats> {
  @override
  final int typeId = 2;

  @override
  PetStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetStats(
      strength: fields[0] as int,
      agility: fields[1] as int,
      intelligence: fields[2] as int,
      endurance: fields[3] as int,
      maxHp: fields[4] as int,
      attackPower: fields[5] as int,
      defense: fields[6] as int,
      speed: fields[7] as int,
      currentHp: fields[8] as int?,
      lastRegenMs: fields[9] == null ? 0 : fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PetStats obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.strength)
      ..writeByte(1)
      ..write(obj.agility)
      ..writeByte(2)
      ..write(obj.intelligence)
      ..writeByte(3)
      ..write(obj.endurance)
      ..writeByte(4)
      ..write(obj.maxHp)
      ..writeByte(5)
      ..write(obj.attackPower)
      ..writeByte(6)
      ..write(obj.defense)
      ..writeByte(7)
      ..write(obj.speed)
      ..writeByte(8)
      ..write(obj.currentHp)
      ..writeByte(9)
      ..write(obj.lastRegenMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 3;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      petId: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      eggTypeIndex: fields[3] as int,
      evolutionStageIndex: fields[4] as int,
      level: fields[5] as int,
      experience: fields[6] as int,
      evolutionPoints: fields[7] as int,
      stats: fields[8] as PetStats,
      skills: (fields[9] as List).cast<PetSkill>(),
      skillSlots: fields[10] as int,
      isHatched: fields[11] as bool,
      hatchTimeMs: fields[12] as int,
      feedingHistory: (fields[13] as Map).cast<String, int>(),
      battleCount: fields[14] as int,
      winCount: fields[15] as int,
      spriteId: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.petId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.eggTypeIndex)
      ..writeByte(4)
      ..write(obj.evolutionStageIndex)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.experience)
      ..writeByte(7)
      ..write(obj.evolutionPoints)
      ..writeByte(8)
      ..write(obj.stats)
      ..writeByte(9)
      ..write(obj.skills)
      ..writeByte(10)
      ..write(obj.skillSlots)
      ..writeByte(11)
      ..write(obj.isHatched)
      ..writeByte(12)
      ..write(obj.hatchTimeMs)
      ..writeByte(13)
      ..write(obj.feedingHistory)
      ..writeByte(14)
      ..write(obj.battleCount)
      ..writeByte(15)
      ..write(obj.winCount)
      ..writeByte(16)
      ..write(obj.spriteId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
