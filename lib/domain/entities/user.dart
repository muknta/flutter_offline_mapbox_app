import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

class User extends Equatable {
  const User({required this.id, required this.nickname, required this.createdAt, required this.updatedAt});

  final String id;
  final String nickname;
  final DateTime createdAt;
  final DateTime updatedAt;

  User.fromLocalJson(Map<String, dynamic> json)
      : id = json[UsersSchema.id],
        nickname = json[UsersSchema.nickname],
        createdAt = DateTime.fromMillisecondsSinceEpoch(json[UsersSchema.createdAt] as int),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(json[UsersSchema.updatedAt] as int);

  Map<String, dynamic> toLocalJson() => {
        UsersSchema.id: id,
        UsersSchema.nickname: nickname,
        UsersSchema.createdAt: createdAt.millisecondsSinceEpoch,
        UsersSchema.updatedAt: updatedAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [id, nickname, createdAt, updatedAt];
}
