// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 0;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      title: fields[0] as String,
      audioUrl: fields[1] as String,
      progressInSeconds: fields[2] as int,
      podcastTitle: fields[3] as String,
      totalDurationInSeconds: fields[4] as int,
      albumArtData: fields[5] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.audioUrl)
      ..writeByte(2)
      ..write(obj.progressInSeconds)
      ..writeByte(3)
      ..write(obj.podcastTitle)
      ..writeByte(4)
      ..write(obj.totalDurationInSeconds)
      ..writeByte(5)
      ..write(obj.albumArtData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
