import 'package:flutter/foundation.dart';
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

  Future<List<dynamic>> getCommentsByUser(String userId) async {
    try {
      List<dynamic> comments = await _sqliteClient.db!.query(
        CommentsSchema.tableName,
        where: '${CommentsSchema.userId} = ?',
        whereArgs: [userId],
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
        CommentsSchema.createdAt: DateTime.now().millisecondsSinceEpoch,
        CommentsSchema.updatedAt: DateTime.now().millisecondsSinceEpoch,
      });
      return id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> editComment({required String id, required String text}) async {
    try {
      await _sqliteClient.db!.update(
        CommentsSchema.tableName,
        {CommentsSchema.text: text},
        where: '${CommentsSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _sqliteClient.db!.delete(
        CommentsSchema.tableName,
        where: '${CommentsSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCommentsByPoint(String pointId) async {
    try {
      await _sqliteClient.db!.delete(
        CommentsSchema.tableName,
        where: '${CommentsSchema.pointId} = ?',
        whereArgs: [pointId],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCommentsByUser(String userId) async {
    try {
      await _sqliteClient.db!.delete(
        CommentsSchema.tableName,
        where: '${CommentsSchema.userId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
