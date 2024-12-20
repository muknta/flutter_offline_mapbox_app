import 'dart:async';

import 'package:crypt/crypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/exceptions.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthService {
  AuthService(this._usersDao, this._sessionService);

  final UsersDao _usersDao;
  final SessionService _sessionService;

  Future<void> signUp({
    required String nickname,
    required String password,
  }) async {
    try {
      if (await _usersDao.getUserByNickname(nickname) != null) {
        throw const AlreadyExistsException();
      }
      final hashedPassword = Crypt.sha256(password).toString();
      final id = await _usersDao.insertUser(nickname: nickname, hashedPassword: hashedPassword);
      _sessionService.loginUser(User(id: id, nickname: nickname));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signIn({
    required String nickname,
    required String password,
  }) async {
    try {
      final userJson = await _usersDao.getUserByNickname(nickname);
      if (userJson == null) {
        throw const NotFoundException();
      }
      final user = User.fromLocalJson(userJson);
      final hashedPassword = Crypt.sha256(password).toString();
      if (hashedPassword != await _usersDao.getHashedPasswordByUserId(user.id)) {
        throw const NotFoundException();
      }
      _sessionService.loginUser(user);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> logOut() async {
    _sessionService.logoutUser();
  }
}
