import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

class User extends Equatable {
  const User({required this.id, required this.name});

  final String id;
  final String name;

  User.fromLocalJson(Map<String, dynamic> json)
      : id = json[UsersSchema.id],
        name = json[UsersSchema.name];

  Map<String, dynamic> toLocalJson() => {
        UsersSchema.id: id,
        UsersSchema.name: name,
      };

  @override
  List<Object?> get props => [id, name];
}
