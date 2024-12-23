import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.resources,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String text;
  final User user;
  final List<CommentResource> resources;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment.fromLocalJson(
    Map<String, dynamic> json, {
    required this.user,
    required List<dynamic> commentResources,
  })  : id = json[CommentsSchema.id],
        text = json[CommentsSchema.text],
        resources =
            commentResources.map((item) => CommentResource.fromLocalJson(item as Map<String, dynamic>)).toList(),
        createdAt = DateTime.fromMillisecondsSinceEpoch(json[CommentsSchema.createdAt] as int),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(json[CommentsSchema.updatedAt] as int);

  Map<String, dynamic> toLocalJson({required String pointId}) => {
        CommentsSchema.id: id,
        CommentsSchema.text: text,
        CommentsSchema.userId: user.id,
        CommentsSchema.pointId: pointId,
        CommentsSchema.createdAt: createdAt.millisecondsSinceEpoch,
        CommentsSchema.updatedAt: updatedAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [id, text, resources, createdAt, updatedAt];
}

class CommentResource extends Equatable {
  const CommentResource({
    required this.id,
    required this.name,
    required this.extension,
  });

  final String id;
  final String name;
  final String extension;

  CommentResourceType get type {
    switch (extension) {
      case 'jpg':
      case 'png':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'svg':
      case 'heic':
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
        name = json[CommentResourcesSchema.name],
        extension = json[CommentResourcesSchema.extension];

  Map<String, dynamic> toLocalJson({required String commentId}) => {
        CommentResourcesSchema.id: id,
        CommentResourcesSchema.name: name,
        CommentResourcesSchema.extension: extension,
        CommentResourcesSchema.commentId: commentId,
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
