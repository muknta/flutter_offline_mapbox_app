import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/storage_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class CommentsDao {
  CommentsDao(this._storageClient);

  final StorageClient _storageClient;

  Future<List<dynamic>> getCommentsByPoint(String pointId) async {
    try {
      List<dynamic> comments = await _storageClient.db!.query(
        CommentsSchema.tableName,
        where: '${CommentsSchema.pointId} = ?',
        whereArgs: [pointId],
      );
      return comments;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> insertComment({required String text, required String userId, required String pointId}) async {
    try {
      await _storageClient.db!.insert(CommentsSchema.tableName, {
        CommentsSchema.id: const Uuid().v4(),
        CommentsSchema.text: text,
        CommentsSchema.userId: userId,
        CommentsSchema.pointId: pointId,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
