// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api-model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiModelAdapter extends TypeAdapter<ApiModel> {
  @override
  final int typeId = 1;

  @override
  ApiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiModel()
      ..apiType = fields[0] as String
      ..apiKey = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, ApiModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.apiType)
      ..writeByte(1)
      ..write(obj.apiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
