// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CookieAdapter extends TypeAdapter<Cookie> {
  @override
  final int typeId = 2;

  @override
  Cookie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cookie(
      cookie: fields[0] as String,
      name: fields[1] as String,
      isMain: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Cookie obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cookie)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isMain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CookieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
