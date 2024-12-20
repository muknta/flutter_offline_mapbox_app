import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/comment_resources_schema.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/storage_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class UsersDao {
  UsersDao(this._storageClient);

  final StorageClient _storageClient;

  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      List<dynamic> users = await _storageClient.db!.query(
        UsersSchema.tableName,
        where: '${UsersSchema.id} = ?',
        whereArgs: [id],
      );
      return users.firstOrNull;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> insertUser({required String name}) async {
    try {
      await _storageClient.db!.insert(UsersSchema.tableName, {
        UsersSchema.id: const Uuid().v4(),
        UsersSchema.name: name,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
