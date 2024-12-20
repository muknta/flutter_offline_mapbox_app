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

  /// Returns user json
  Future<Map<String, dynamic>> insertUser({required String nickname, required String hashedPassword}) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await _sqliteClient.db!.insert(UsersSchema.tableName, {
        UsersSchema.id: id,
        UsersSchema.nickname: nickname,
        UsersSchema.hashedPassword: hashedPassword,
        UsersSchema.createdAt: now,
        UsersSchema.updatedAt: now,
      });
      return {
        UsersSchema.id: id,
        UsersSchema.nickname: nickname,
        UsersSchema.hashedPassword: hashedPassword,
        UsersSchema.createdAt: now,
        UsersSchema.updatedAt: now,
      };
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateUser({required String id, String? nickname, String? hashedPassword}) async {
    if (nickname == null && hashedPassword == null) {
      return;
    }
    try {
      await _sqliteClient.db!.update(
        UsersSchema.tableName,
        {
          if (nickname != null) UsersSchema.nickname: nickname,
          if (hashedPassword != null) UsersSchema.hashedPassword: hashedPassword,
          UsersSchema.updatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '${UsersSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _sqliteClient.db!.delete(
        UsersSchema.tableName,
        where: '${UsersSchema.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
