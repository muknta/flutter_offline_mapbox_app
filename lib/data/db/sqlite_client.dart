import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';

import 'schemas/exports.dart';

@lazySingleton
class SqliteClient {
  SqliteClient();

  late final Database? _db;

  Database? get db => _db;

  static const _path = 'mapbox_app.db';
  static const _uuidLength = 36;

  @PostConstruct(preResolve: true)
  Future<void> open() async {
    _db = await openDatabase(_path, onCreate: (Database db, int version) async {
      await db.execute('''
CREATE TABLE ${UsersSchema.tableName} ( 
  ${UsersSchema.id} TEXT PRIMARY KEY
  CHECK(
    LENGTH("${UsersSchema.id}") == $_uuidLength
  ),
  ${UsersSchema.nickname} TEXT UNIQUE NOT NULL,
  ${UsersSchema.hashedPassword} TEXT NOT NULL
)

CREATE TABLE ${PointsSchema.tableName} ( 
  ${PointsSchema.id} TEXT PRIMARY KEY
  CHECK(
    LENGTH("${PointsSchema.id}") == $_uuidLength
  ),
  ${PointsSchema.lat} REAL NOT NULL, 
  ${PointsSchema.lng} REAL NOT NULL,
  ${PointsSchema.userId} TEXT NOT NULL,
  CONSTRAINT fk_users
    FOREIGN KEY (${PointsSchema.userId})
    REFERENCES ${UsersSchema.tableName}(${UsersSchema.id})
)

CREATE TABLE ${CommentsSchema.tableName} ( 
  ${CommentsSchema.id} TEXT PRIMARY KEY
  CHECK(
    LENGTH("${CommentsSchema.id}") == $_uuidLength
  ),
  ${CommentsSchema.text} TEXT NOT NULL,
  ${CommentsSchema.pointId} TEXT NOT NULL,
  ${CommentsSchema.userId} TEXT NOT NULL,
  CONSTRAINT fk_points
    FOREIGN KEY (${CommentsSchema.pointId})
    REFERENCES ${PointsSchema.tableName}(${PointsSchema.id}),
  CONSTRAINT fk_users
    FOREIGN KEY (${CommentsSchema.userId})
    REFERENCES ${UsersSchema.tableName}(${UsersSchema.id})
)

CREATE TABLE ${CommentResourcesSchema.tableName} ( 
  ${CommentResourcesSchema.id} TEXT PRIMARY KEY,
  ${CommentResourcesSchema.commentId} TEXT NOT NULL,
  CONSTRAINT fk_comments
    FOREIGN KEY (${CommentResourcesSchema.commentId})
    REFERENCES ${CommentsSchema.tableName}(${CommentsSchema.id})
)
''');
    });
  }

  @disposeMethod
  Future<void> close() async => _db?.close();
}
