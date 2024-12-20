import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

import 'comment.dart';
import 'user.dart';

class Point extends Equatable {
  const Point({
    required this.id,
    required this.name,
    required this.coordinates,
    this.user,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final Coordinates coordinates;
  final User? user;
  final List<Comment>? comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Point.fromLocalJson(Map<String, dynamic> json, {this.user, this.comments})
      : id = json[PointsSchema.id],
        name = json[PointsSchema.name],
        coordinates = Coordinates.fromLocalJson(json),
        createdAt = DateTime.fromMillisecondsSinceEpoch(json[PointsSchema.createdAt] as int),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(json[PointsSchema.updatedAt] as int);

  Map<String, dynamic> toLocalJson() => {
        PointsSchema.id: id,
        PointsSchema.name: name,
        ...coordinates.toLocalJson(),
        PointsSchema.userId: user?.id,
        PointsSchema.createdAt: createdAt.millisecondsSinceEpoch,
        PointsSchema.updatedAt: updatedAt.millisecondsSinceEpoch,
      };

  Point copyWithExtra({
    User? user,
    List<Comment>? comments,
  }) {
    return Point(
      id: id,
      name: name,
      coordinates: coordinates,
      user: user ?? this.user,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, coordinates, user, comments, createdAt, updatedAt];
}

class Coordinates extends Equatable {
  const Coordinates({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Coordinates.fromLocalJson(Map<String, dynamic> json)
      : lat = json[PointsSchema.lat],
        lng = json[PointsSchema.lng];

  Map<String, dynamic> toLocalJson() => {
        PointsSchema.lat: lat,
        PointsSchema.lng: lng,
      };

  @override
  List<Object?> get props => [lat, lng];
}
