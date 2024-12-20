import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

class User extends Equatable {
  const User({required this.id, required this.nickname});

  final String id;
  final String nickname;

  User.fromLocalJson(Map<String, dynamic> json)
      : id = json[UsersSchema.id],
        nickname = json[UsersSchema.nickname];

  Map<String, dynamic> toLocalJson() => {
        UsersSchema.id: id,
        UsersSchema.nickname: nickname,
      };

  @override
  List<Object?> get props => [id, nickname];
}
