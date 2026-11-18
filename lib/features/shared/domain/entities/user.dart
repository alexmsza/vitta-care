import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole { family, pro, admin }

enum UserStatus { active, pending, blocked }

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    required UserRole role,
    @Default(UserStatus.pending) UserStatus status,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
