// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackItemAdapter extends TypeAdapter<FeedbackItem> {
  @override
  final int typeId = 9;

  @override
  FeedbackItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedbackItem(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String,
      type: fields[4] as FeedbackType,
      subject: fields[5] as String,
      message: fields[6] as String,
      createdAt: fields[7] as DateTime,
      status: fields[8] as FeedbackStatus,
    );
  }

  @override
  void write(BinaryWriter writer, FeedbackItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.message)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FeedbackTypeAdapter extends TypeAdapter<FeedbackType> {
  @override
  final int typeId = 10;

  @override
  FeedbackType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeedbackType.bug;
      case 1:
        return FeedbackType.feature;
      case 2:
        return FeedbackType.general;
      case 3:
        return FeedbackType.complaint;
      case 4:
        return FeedbackType.compliment;
      default:
        return FeedbackType.bug;
    }
  }

  @override
  void write(BinaryWriter writer, FeedbackType obj) {
    switch (obj) {
      case FeedbackType.bug:
        writer.writeByte(0);
        break;
      case FeedbackType.feature:
        writer.writeByte(1);
        break;
      case FeedbackType.general:
        writer.writeByte(2);
        break;
      case FeedbackType.complaint:
        writer.writeByte(3);
        break;
      case FeedbackType.compliment:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FeedbackStatusAdapter extends TypeAdapter<FeedbackStatus> {
  @override
  final int typeId = 11;

  @override
  FeedbackStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeedbackStatus.submitted;
      case 1:
        return FeedbackStatus.inReview;
      case 2:
        return FeedbackStatus.resolved;
      case 3:
        return FeedbackStatus.closed;
      default:
        return FeedbackStatus.submitted;
    }
  }

  @override
  void write(BinaryWriter writer, FeedbackStatus obj) {
    switch (obj) {
      case FeedbackStatus.submitted:
        writer.writeByte(0);
        break;
      case FeedbackStatus.inReview:
        writer.writeByte(1);
        break;
      case FeedbackStatus.resolved:
        writer.writeByte(2);
        break;
      case FeedbackStatus.closed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackItem _$FeedbackItemFromJson(Map<String, dynamic> json) => FeedbackItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type']),
      subject: json['subject'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecodeNullable(_$FeedbackStatusEnumMap, json['status']) ??
          FeedbackStatus.submitted,
    );

Map<String, dynamic> _$FeedbackItemToJson(FeedbackItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'subject': instance.subject,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$FeedbackStatusEnumMap[instance.status]!,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.bug: 'bug',
  FeedbackType.feature: 'feature',
  FeedbackType.general: 'general',
  FeedbackType.complaint: 'complaint',
  FeedbackType.compliment: 'compliment',
};

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.submitted: 'submitted',
  FeedbackStatus.inReview: 'inReview',
  FeedbackStatus.resolved: 'resolved',
  FeedbackStatus.closed: 'closed',
};
