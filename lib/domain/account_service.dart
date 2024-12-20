import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/dao/comment_resources_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/comments_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/points_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class AccountService {
  AccountService(this._usersDao, this._sessionService, this._pointsDao, this._commentsDao, this._commentResourcesDao);

  final UsersDao _usersDao;
  final PointsDao _pointsDao;
  final CommentsDao _commentsDao;
  final CommentResourcesDao _commentResourcesDao;
  final SessionService _sessionService;

  Future<void> updateNickname({required String id, required String nickname}) async {
    try {
      await _usersDao.updateUser(id: id, nickname: nickname);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteUser({required String id}) async {
    try {
      final comments = await _commentsDao.getCommentsByUser(id);
      for (final comment in comments) {
        await _commentResourcesDao.deleteResourcesByComment(comment.id);
      }
      await _commentsDao.deleteCommentsByUser(id);
      await _pointsDao.deletePointsByUser(id);
      await _usersDao.deleteUser(id);
      _sessionService.logoutUser();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
