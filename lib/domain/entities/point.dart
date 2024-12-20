import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

import 'comment.dart';
import 'user.dart';

class Point extends Equatable {
  const Point({
    required this.id,
    required this.coordinates,
    this.user,
    this.comments,
  });

  final String id;
  final Coordinates coordinates;
  final User? user;
  final List<Comment>? comments;

  Point.fromLocalJson(Map<String, dynamic> json, {this.user, this.comments})
      : id = json[PointsSchema.id],
        coordinates = Coordinates.fromLocalJson(json);

  Map<String, dynamic> toLocalJson() => {
        PointsSchema.id: id,
        ...coordinates.toLocalJson(),
      };

  @override
  List<Object?> get props => [id, coordinates, user, comments];
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
