import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

import 'point.dart';
import 'user.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.point,
    required this.resources,
  });

  final String id;
  final String text;
  final User user;
  final Point point;
  final List<CommentResource> resources;

  Comment.fromLocalJson(
    Map<String, dynamic> json, {
    required Map<String, dynamic> userJson,
    required Map<String, dynamic> pointJson,
    required List<Map<String, dynamic>> commentResources,
  })  : id = json[CommentsSchema.id],
        text = json[CommentsSchema.text],
        user = User.fromLocalJson(userJson),
        point = Point.fromLocalJson(pointJson),
        resources = commentResources.map((item) => CommentResource.fromLocalJson(item)).toList();

  Map<String, dynamic> toLocalJson() => {
        CommentsSchema.id: id,
        CommentsSchema.text: text,
        CommentsSchema.userId: user.id,
        CommentsSchema.pointId: point.id,
      };

  @override
  List<Object?> get props => [id, text];
}

class CommentResource extends Equatable {
  const CommentResource({
    required this.id,
    required this.extension,
  });

  final String id;
  final String extension;

  CommentResourceType get type {
    switch (extension) {
      case 'jpg':
      case 'png':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'svg':
        return CommentResourceType.image;
      case 'mp4':
      case 'webm':
      case 'mov':
        return CommentResourceType.video;
      default:
        throw UnsupportedError('Unsupported extension: $extension');
    }
  }

  CommentResource.fromLocalJson(Map<String, dynamic> json)
      : id = json[CommentResourcesSchema.id],
        extension = json[CommentResourcesSchema.extension];

  Map<String, dynamic> toLocalJson() => {
        CommentResourcesSchema.id: id,
        CommentResourcesSchema.extension: extension,
      };

  @override
  String toString() => '$id.$extension';

  @override
  List<Object?> get props => [id, extension];
}

enum CommentResourceType {
  image,
  video,
}
