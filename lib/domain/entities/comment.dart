import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.text,
    required this.resources,
  });

  final String id;
  final String text;
  final List<CommentResource> resources;

  Comment.fromLocalJson(
    Map<String, dynamic> json, {
    required List<dynamic> commentResources,
  })  : id = json[CommentsSchema.id],
        text = json[CommentsSchema.text],
        resources =
            commentResources.map((item) => CommentResource.fromLocalJson(item as Map<String, dynamic>)).toList();

  Map<String, dynamic> toLocalJson() => {
        CommentsSchema.id: id,
        CommentsSchema.text: text,
      };

  @override
  List<Object?> get props => [id, text];
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

  Map<String, dynamic> toLocalJson() => {
        CommentResourcesSchema.id: id,
        CommentResourcesSchema.name: name,
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
