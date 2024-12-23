import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/dao/comment_resources_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/comments_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/points_dao.dart';
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart';
import 'package:flutter_offline_mapbox/data/db/schemas/exports.dart';
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart';
import 'package:flutter_offline_mapbox/domain/entities/comment.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/exceptions.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

@injectable
class MapsMetadataService {
  const MapsMetadataService(
    this._usersDao,
    this._commentsDao,
    this._commentResourcesDao,
    this._pointsDao,
    this._sessionService,
    this._prefsClient,
  );

  final UsersDao _usersDao;
  final CommentsDao _commentsDao;
  final CommentResourcesDao _commentResourcesDao;
  final PointsDao _pointsDao;
  final SessionService _sessionService;
  final SharedPrefsClient _prefsClient;

  Coordinates? getInitialPosition() {
    return _prefsClient.getInitialPosition();
  }

  Future<void> insertComment({
    required String text,
    required List<XFile> resources,
    required String userId,
    required String pointId,
  }) async {
    try {
      final failedFiles = <XFile>[];
      // NOTE: need to be copied from parameters, otherwise will be cleared
      final res = resources.toList();
      final commentId = await _commentsDao.insertComment(
        text: text,
        userId: userId,
        pointId: pointId,
      );
      for (final resource in res) {
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        final nameParts = resource.name.split('.');
        final name = nameParts.sublist(0, nameParts.length - 1).join('.');
        final extension = nameParts[nameParts.length - 1];
        final cachedResource = CommentResource(
          id: const Uuid().v4(),
          name: name,
          extension: extension,
        );
        try {
          await resource.saveTo('$path/${cachedResource.toString()}');
          await _commentResourcesDao.insertResource(
            id: cachedResource.id,
            name: cachedResource.name,
            extension: cachedResource.extension,
            commentId: commentId,
          );
        } catch (e) {
          debugPrint(e.toString());
          failedFiles.add(resource);
        }
      }
      if (failedFiles.isNotEmpty) {
        throw FailedFilesException(failedFiles);
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> editComment({required String id, required String text}) async {
    try {
      await _commentsDao.editComment(id: id, text: text);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> insertPoint({
    required double lat,
    required double lng,
    required String? name,
  }) async {
    try {
      final user = _sessionService.currentUser;
      if (user == null) {
        throw const NotAuthenticatedException();
      }
      await _pointsDao.insertPoint(lat: lat, lng: lng, name: name, userId: user.id);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<Point>> getAllPoints() async {
    try {
      final pointsJson = await _pointsDao.getAllPoints();
      List<Point> points = [];
      for (final point in pointsJson) {
        final userJson = await _usersDao.getUserById(point[PointsSchema.userId]);
        points.add(Point.fromLocalJson(
          point as Map<String, dynamic>,
          user: userJson == null ? null : User.fromLocalJson(userJson),
        ));
      }
      return points;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<Point>> getMyPoints() async {
    final user = _sessionService.currentUser;
    if (user == null) {
      return [];
    }
    try {
      final pointsJson = await _pointsDao.getPointsByUser(user.id);
      return pointsJson.map((item) => Point.fromLocalJson(item as Map<String, dynamic>, user: user)).toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Point?> getDetailedPointByCoordinates({required double lat, required double lng}) async {
    try {
      final pointJson = await _pointsDao.getPointByCoordinates(lat: lat, lng: lng);
      if (pointJson == null) {
        return null;
      }
      return getDetailedPoint(Point.fromLocalJson(pointJson));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Point> getDetailedPoint(Point point, {bool forceUpdate = false}) async {
    try {
      if (!forceUpdate && point.user != null && point.comments != null) {
        return point;
      }
      Point result = point;

      User? user = point.user;
      if (user == null || forceUpdate) {
        final pointJson = (await _pointsDao.getPointById(point.id));
        if (pointJson == null) {
          throw const NotFoundException();
        }
        final userId = pointJson[PointsSchema.userId];
        final userJson = await _usersDao.getUserById(userId);
        if (userJson != null) {
          user = User.fromLocalJson(userJson);
        }
        result = result.copyWithExtra(user: user);
      }
      if (point.comments == null || forceUpdate) {
        final commentsJson = await _commentsDao.getCommentsByPoint(point.id);
        List<Comment> comments = [];
        for (final comment in commentsJson) {
          final commentResourcesJson = await _commentResourcesDao.getResourcesByComment(comment[CommentsSchema.id]);
          comments.add(
            Comment.fromLocalJson(
              comment as Map<String, dynamic>,
              user: result.user!,
              commentResources: commentResourcesJson,
            ),
          );
        }
        result = result.copyWithExtra(comments: comments);
      }
      return result;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deletePoint(String id) async {
    try {
      final comments = await _commentsDao.getCommentsByPoint(id);
      for (final comment in comments) {
        await _commentResourcesDao.deleteResourcesByComment(comment.id);
      }
      await _commentsDao.deleteCommentsByPoint(id);
      await _pointsDao.deletePoint(id);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deletePointByCoordinates({required double lat, required double lng}) async {
    try {
      final point = await _pointsDao.getPointByCoordinates(lat: lat, lng: lng);
      if (point == null) {
        return;
      }
      await deletePoint(point['id']);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _commentResourcesDao.deleteResourcesByComment(id);
      await _commentsDao.deleteComment(id);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
