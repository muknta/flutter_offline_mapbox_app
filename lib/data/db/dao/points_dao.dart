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
      });
      return id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
