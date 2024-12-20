import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/db/sqlite_client.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@injectable
class UsersDao {
  UsersDao(this._sqliteClient);

  final SqliteClient _sqliteClient;

  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      List<dynamic> users = await _sqliteClient.db!.query(
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

  Future<Map<String, dynamic>?> getUserByNickname(String nickname) async {
    try {
      List<dynamic> users = await _sqliteClient.db!.query(
        UsersSchema.tableName,
        where: '${UsersSchema.nickname} = ?',
        whereArgs: [nickname],
      );
      return users.firstOrNull;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String?> getHashedPasswordByUserId(String userId) async {
    try {
      List<dynamic> users = await _sqliteClient.db!.query(
        UsersSchema.tableName,
        where: '${UsersSchema.id} = ?',
        whereArgs: [userId],
      );
      return users.firstOrNull?[UsersSchema.hashedPassword];
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Returns user id
  Future<String> insertUser({required String nickname, required String hashedPassword}) async {
    try {
      final id = const Uuid().v4();
      await _sqliteClient.db!.insert(UsersSchema.tableName, {
        UsersSchema.id: id,
        UsersSchema.nickname: nickname,
        UsersSchema.hashedPassword: hashedPassword,
      });
      return id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
