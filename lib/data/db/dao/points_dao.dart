import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/sqlite_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class PointsDao {
  PointsDao(this._sqliteClient);

  final SqliteClient _sqliteClient;

  Future<List<dynamic>> getAllPoints() async {
    try {
      List<dynamic> points = await _sqliteClient.db!.query(PointsSchema.tableName);
      return points;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<dynamic>> getPointsByUser(String userId) async {
    try {
      List<dynamic> points = await _sqliteClient.db!.query(
        PointsSchema.tableName,
        where: '${PointsSchema.userId} = ?',
        whereArgs: [userId],
      );
      return points;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPointById(String id) async {
    try {
      List<dynamic> points = await _sqliteClient.db!.query(
        PointsSchema.tableName,
        where: '${PointsSchema.id} = ?',
        whereArgs: [id],
      );
      return points.firstOrNull as Map<String, dynamic>?;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Returns point id
  Future<String> insertPoint({required double lat, required double lng, required String userId}) async {
    try {
      final id = const Uuid().v4();
      await _sqliteClient.db!.insert(PointsSchema.tableName, {
        PointsSchema.id: id,
        PointsSchema.lat: lat,
        PointsSchema.lng: lng,
        PointsSchema.userId: userId,
        PointsSchema.createdAt: DateTime.now().millisecondsSinceEpoch,
        PointsSchema.updatedAt: DateTime.now().millisecondsSinceEpoch,
      });
      return id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> triggerUpdatePoint({required String id}) async {
    try {
      await _sqliteClient.db!.update(
        PointsSchema.tableName,
        {
          PointsSchema.updatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '${PointsSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deletePoint(String id) async {
    try {
      await _sqliteClient.db!.delete(
        PointsSchema.tableName,
        where: '${PointsSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deletePointsByUser(String userId) async {
    try {
      await _sqliteClient.db!.delete(
        PointsSchema.tableName,
        where: '${PointsSchema.userId} = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
