// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.pending,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'avatarUrl': instance.avatarUrl,
    };

const _$UserRoleEnumMap = {
  UserRole.family: 'family',
  UserRole.pro: 'pro',
  UserRole.admin: 'admin',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.pending: 'pending',
  UserStatus.blocked: 'blocked',
};
