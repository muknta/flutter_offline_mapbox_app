import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/sqlite_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class CommentsDao {
  CommentsDao(this._sqliteClient);

  final SqliteClient _sqliteClient;

  Future<List<dynamic>> getCommentsByPoint(String pointId) async {
    try {
      List<dynamic> comments = await _sqliteClient.db!.query(
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

  /// Returns comment id
  Future<String> insertComment({required String text, required String userId, required String pointId}) async {
    try {
      final id = const Uuid().v4();
      await _sqliteClient.db!.insert(CommentsSchema.tableName, {
        CommentsSchema.id: id,
        CommentsSchema.text: text,
        CommentsSchema.userId: userId,
        CommentsSchema.pointId: pointId,
      });
      return id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
