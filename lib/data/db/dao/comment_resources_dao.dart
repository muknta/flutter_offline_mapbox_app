import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/sqlite_client.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommentResourcesDao {
  CommentResourcesDao(this._sqliteClient);

  final SqliteClient _sqliteClient;

  Future<List<dynamic>> getResourcesByComment(String commentId) async {
    try {
      List<dynamic> resources = await _sqliteClient.db!.query(
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

  Future<void> insertResource({
    required String id,
    required String name,
    required String extension,
    required String commentId,
  }) async {
    try {
      await _sqliteClient.db!.insert(CommentResourcesSchema.tableName, {
        CommentResourcesSchema.id: id,
        CommentResourcesSchema.name: name,
        CommentResourcesSchema.extension: extension,
        CommentResourcesSchema.commentId: commentId,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteResource(String id) async {
    try {
      await _sqliteClient.db!.delete(
        CommentResourcesSchema.tableName,
        where: '${CommentResourcesSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteResourcesByComment(String commentId) async {
    try {
      await _sqliteClient.db!.delete(
        CommentResourcesSchema.tableName,
        where: '${CommentResourcesSchema.commentId} = ?',
        whereArgs: [commentId],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
