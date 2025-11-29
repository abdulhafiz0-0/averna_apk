import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String role;
  final String? email;
  @JsonKey(name: 'full_name')
  final String? fullName;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.email,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperadmin => role == 'superadmin';
  bool get isTeacher => role == 'teacher';
}
