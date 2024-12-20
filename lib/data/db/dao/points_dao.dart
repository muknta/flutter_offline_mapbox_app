import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/storage_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class PointsDao {
  PointsDao(this._storageClient);

  final StorageClient _storageClient;

  Future<List<dynamic>> getPointsByUser(String userId) async {
    try {
      List<dynamic> points = await _storageClient.db!.query(
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

  Future<void> insertPoint({required double lat, required double lng, required String userId}) async {
    try {
      await _storageClient.db!.insert(PointsSchema.tableName, {
        PointsSchema.id: const Uuid().v4(),
        PointsSchema.lat: lat,
        PointsSchema.lng: lng,
        PointsSchema.userId: userId,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
