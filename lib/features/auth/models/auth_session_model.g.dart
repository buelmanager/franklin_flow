// lib/features/auth/models/auth_session_model.g.dart

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthSessionAdapter extends TypeAdapter<AuthSession> {
  @override
  final int typeId = 10;

  @override
  AuthSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthSession(
      userId: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      profileImageUrl: fields[3] as String?,
      provider: fields[4] as String,
      createdAt: fields[5] as DateTime,
      lastActiveAt: fields[6] as DateTime,
      expiresAt: fields[7] as DateTime?,
      kakaoAccessToken: fields[8] as String?,
      kakaoRefreshToken: fields[9] as String?,
      kakaoTokenExpiresAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.profileImageUrl)
      ..writeByte(4)
      ..write(obj.provider)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastActiveAt)
      ..writeByte(7)
      ..write(obj.expiresAt)
      ..writeByte(8)
      ..write(obj.kakaoAccessToken)
      ..writeByte(9)
      ..write(obj.kakaoRefreshToken)
      ..writeByte(10)
      ..write(obj.kakaoTokenExpiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
