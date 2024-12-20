import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/storage_client.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommentResourcesDao {
  CommentResourcesDao(this._storageClient);

  final StorageClient _storageClient;

  Future<List<dynamic>> getResourcesByComment(String commentId) async {
    try {
      List<dynamic> resources = await _storageClient.db!.query(
        CommentResourcesSchema.tableName,
        where: '${CommentResourcesSchema.commentId} = ?',
        whereArgs: [commentId],
      );
      return resources;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> insertResource({required String id, required String extension, required String commentId}) async {
    try {
      await _storageClient.db!.insert(CommentResourcesSchema.tableName, {
        CommentResourcesSchema.id: id,
        CommentResourcesSchema.extension: extension,
        CommentResourcesSchema.commentId: commentId,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
