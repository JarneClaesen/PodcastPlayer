// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PodcastAdapter extends TypeAdapter<Podcast> {
  @override
  final int typeId = 1;

  @override
  Podcast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Podcast(
      title: fields[0] as String,
      episodes: (fields[1] as List).cast<Episode>(),
    );
  }

  @override
  void write(BinaryWriter writer, Podcast obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.episodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
