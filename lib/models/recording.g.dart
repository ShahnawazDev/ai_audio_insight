// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordingAdapter extends TypeAdapter<Recording> {
  @override
  final int typeId = 0;

  @override
  Recording read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recording(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      transcribedText: fields[3] as String,
      summarizedText: fields[4] as String,
      path: fields[5] as String,
      date: fields[6] as DateTime,
      duration: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Recording obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.transcribedText)
      ..writeByte(4)
      ..write(obj.summarizedText)
      ..writeByte(5)
      ..write(obj.path)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
